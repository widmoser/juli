grammar JL;

options {
  language = C;
}

@includes {
  #include <iostream>
  #include <string>
  #include <sstream>
  #include <cstdio>
  
  #include <parser/ast/ast.h>
  #include <parser/ast/translationUnit.h>
  #include <parser/antlr/antlr_utils.h>
  #include <parser/ast/types.h>
}

@postinclude {
  juli::TranslationUnit* translationUnit;
}

translation_unit [const char* moduleName] returns [juli::TranslationUnit* result]:
{ 
  result = new juli::TranslationUnit("test");
  translationUnit = result;
}
(stmt=statement { result->addStatement(stmt); })+ 
;

statement returns [juli::NStatement* result]: 
stmt1=assignment { result = stmt1; } | 
stmt2=expression_statement { result = stmt2; } |
stmt3=return_statement { result = stmt3; } |
stmt4=function_definition { result = stmt4; } |
stmt5=variable_declaration ';' { result = stmt5; } |
stmt6=function_declaration ';' { result = stmt6; } | 
stmt7=if_statement { result = stmt7; }
;


function_definition returns [juli::NFunctionDefinition* result]:
decl=function_declaration bl=block
{
  result = new juli::NFunctionDefinition(translationUnit, decl, bl);
}
;

block returns [juli::NBlock* result]:
{
  result = new juli::NBlock(translationUnit);
}
'{'
(stmt=statement { result->addStatement(stmt); })*
'}' 
;

if_statement returns [juli::NStatement* result]
@declarations
{
  std::vector<juli::NIfClause*> clauses;
}:
cl=if_clause { clauses.push_back(cl); }
('else' cl=if_clause { clauses.push_back(cl); })*
(cl=else_clause { clauses.push_back(cl); })?
{
  result = new juli::NIfStatement(translationUnit, clauses);
}
;

if_clause returns [juli::NIfClause* result]:
'if' '(' cond=expression ')' bl=block
{
  result = new juli::NIfClause(cond, bl);
}
;

else_clause returns [juli::NIfClause* result]:
'else' bl=block
{
  result = new juli::NIfClause(0, bl);
}
;

function_declaration returns [juli::NFunctionDeclaration* result]
@declarations
{
   juli::VariableList arguments;
   juli::NIdentifier* type;
   juli::NIdentifier* id;
   bool varArgs = false;
}:
sign=variable_declaration { id = sign->id; type = sign->type; }
'(' 
(first_arg=variable_declaration { arguments.push_back(first_arg); }
(',' arg=variable_declaration { arguments.push_back(arg); } )
*)
?
(',' VarArgs { varArgs = true; } )?
')'
{
  result = new juli::NFunctionDeclaration(translationUnit, type, id, arguments, varArgs);
}
;


variable_declaration returns [juli::NVariableDeclaration* result]:
vtype=identifier id=identifier
{
  result = new juli::NVariableDeclaration(translationUnit, vtype, id);
}
;

return_statement returns [juli::NReturnStatement* result]:
{
  result = new juli::NReturnStatement(translationUnit, 0);
}
'return' 
(exp=expression {result = new juli::NReturnStatement(translationUnit, exp);})? 
';'
;

expression_statement returns [juli::NExpressionStatement* result]:
exp=expression ';' { result = new juli::NExpressionStatement(translationUnit, exp); }
;

assignment returns [juli::NAssignment* result]: 
id=identifier '=' exp=expression ';' 
{ result = new juli::NAssignment(translationUnit, id, exp); }
;

expression returns [juli::NExpression* result]
@declarations
{
   juli::Operator type = juli::UNKNOWN;
}
:
  op1=add { result = op1; }
  (
    OP_EQ      { type = juli::EQ; } 
    op2=add  { result = new juli::NBinaryOperator(translationUnit, result, type, op2); }
  )*
;

add returns [juli::NExpression* result]
@declarations
{
   juli::Operator type = juli::UNKNOWN;
}
:
  op1=literal { result=op1; }
  (
    OP_PLUS      { type = juli::PLUS; } 
    op2=literal  { result = new juli::NBinaryOperator(translationUnit, result, type, op2); }
  )*
;



literal returns [juli::NExpression* result]: 
val=double_literal { result = val; } | 
val=string_literal { result = val; } |
val=identifier { result = val; } |
val=function_call { result = val; } | 
'(' val=expression ')' { result = val; }
;

function_call returns [juli::NFunctionCall* result]
@declarations 
{
  juli::ExpressionList arguments;
}:
id=identifier 
  '(' 
    (arg=expression { arguments.push_back(arg); })? 
    (',' arg=expression { arguments.push_back(arg); })* 
  ')'
{
  result = new juli::NFunctionCall(translationUnit, id, arguments);
}
;

identifier returns [juli::NIdentifier* result]:
Identifier { result = new juli::NIdentifier(translationUnit, getTokenString($Identifier)); } 
;

double_literal returns [juli::NDoubleLiteral* result]:
FloatingPointLiteral
{ 
  std::stringstream valueStr(getTokenString($FloatingPointLiteral));
  double value = 0.0;
  valueStr >> value;
  result = new juli::NDoubleLiteral(translationUnit, value); 
} 
;

string_literal returns [juli::NStringLiteral* result]:
StringLiteral
{
  std::string tokenText = getTokenString($StringLiteral);
  tokenText = tokenText.substr(1, tokenText.size() - 2);
  result = new juli::NStringLiteral(translationUnit, tokenText);
}
;

// LEXER

VarArgs : '...' ;

HexLiteral : '0' ('x'|'X') HexDigit+ IntegerTypeSuffix? ;

DecimalLiteral : ('0' | '1'..'9' '0'..'9'*) IntegerTypeSuffix? ;

OctalLiteral : '0' ('0'..'7')+ IntegerTypeSuffix? ;

fragment
HexDigit : ('0'..'9'|'a'..'f'|'A'..'F') ;

fragment
IntegerTypeSuffix : ('l'|'L') ;

FloatingPointLiteral
    :   ('0'..'9')+ '.' ('0'..'9')* Exponent? FloatTypeSuffix?
    |   '.' ('0'..'9')+ Exponent? FloatTypeSuffix?
    |   ('0'..'9')+ Exponent FloatTypeSuffix?
    |   ('0'..'9')+ FloatTypeSuffix
    ;

fragment
Exponent : ('e'|'E') ('+'|'-')? ('0'..'9')+ ;

fragment
FloatTypeSuffix : ('f'|'F'|'d'|'D') ;

CharacterLiteral
    :   '\'' ( EscapeSequence | ~('\''|'\\') ) '\''
    ;

StringLiteral
    :  '"' ( EscapeSequence | ~('\\'|'"') )* '"'
    ;

fragment
EscapeSequence
    :   '\\' ('b'|'t'|'n'|'f'|'r'|'\"'|'\''|'\\')
    |   UnicodeEscape
    |   OctalEscape
    ;

fragment
OctalEscape
    :   '\\' ('0'..'3') ('0'..'7') ('0'..'7')
    |   '\\' ('0'..'7') ('0'..'7')
    |   '\\' ('0'..'7')
    ;

fragment
UnicodeEscape
    :   '\\' 'u' HexDigit HexDigit HexDigit HexDigit
    ;
    
OP_PLUS : '+' ;
OP_EQ : '==' ;
    
Identifier 
    :   Letter (Letter|JavaIDDigit)*
    ;

/**I found this char range in JavaCC's grammar, but Letter and Digit overlap.
   Still works, but...
 */
fragment
Letter
    :  '\u0024' |
       '\u0041'..'\u005a' |
       '\u005f' |
       '\u0061'..'\u007a' |
       '\u00c0'..'\u00d6' |
       '\u00d8'..'\u00f6' |
       '\u00f8'..'\u00ff' |
       '\u0100'..'\u1fff' |
       '\u3040'..'\u318f' |
       '\u3300'..'\u337f' |
       '\u3400'..'\u3d2d' |
       '\u4e00'..'\u9fff' |
       '\uf900'..'\ufaff'
    ;

fragment
JavaIDDigit
    :  '\u0030'..'\u0039' |
       '\u0660'..'\u0669' |
       '\u06f0'..'\u06f9' |
       '\u0966'..'\u096f' |
       '\u09e6'..'\u09ef' |
       '\u0a66'..'\u0a6f' |
       '\u0ae6'..'\u0aef' |
       '\u0b66'..'\u0b6f' |
       '\u0be7'..'\u0bef' |
       '\u0c66'..'\u0c6f' |
       '\u0ce6'..'\u0cef' |
       '\u0d66'..'\u0d6f' |
       '\u0e50'..'\u0e59' |
       '\u0ed0'..'\u0ed9' |
       '\u1040'..'\u1049'
   ;

WS  :  (' '|'\r'|'\t'|'\u000C'|'\n') {$channel=HIDDEN;}
    ;

COMMENT
    :   '/*' ( options {greedy=false;} : . )* '*/' {$channel=HIDDEN;}
    ;

LINE_COMMENT
    : '//' ~('\n'|'\r')* '\r'? '\n' {$channel=HIDDEN;}
    ;

//IDENTIFIER : CHAR ALPHANUM* ;
//DOUBLE_LITERAL : DIGIT+ ('.' DIGIT+)? ;
////NEWLINE : (('\u000C')?('\r')? '\n' )+;
//OP_PLUS : '+' ;
//WS : (' ' | '\t' | '\n' | '\r' | '\f')+ { $channel = HIDDEN; };
//fragment ALPHANUM : ('a'..'z' | 'A'..'Z' | '0'..'9') ;
//fragment CHAR : 'a'..'z' | 'A'..'Z' ;
//fragment DIGIT : '0'..'9' ; 
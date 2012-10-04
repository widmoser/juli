#include "declare.h"

#include <stdexcept>

using namespace juli;

juli::Declarator::Declarator() {
	// implicit declarations:
	std::vector<std::string> comparison;
	comparison.push_back(">");
	comparison.push_back("<");
	comparison.push_back(">=");
	comparison.push_back("<=");
	comparison.push_back("==");
	comparison.push_back("!=");
	declareImplicitOperator(comparison, &PrimitiveType::BOOLEAN_TYPE,
			&PrimitiveType::INT8_TYPE, 2);
	declareImplicitOperator(comparison, &PrimitiveType::BOOLEAN_TYPE,
			&PrimitiveType::INT32_TYPE, 2);
	declareImplicitOperator(comparison, &PrimitiveType::BOOLEAN_TYPE,
			&PrimitiveType::FLOAT64_TYPE, 2);

	std::vector<std::string> equality;
	equality.push_back("==");
	equality.push_back("!=");
	declareImplicitOperator(equality, &PrimitiveType::BOOLEAN_TYPE,
			&PrimitiveType::BOOLEAN_TYPE, 2);

	std::vector<std::string> arithmetic;
	arithmetic.push_back("+");
	arithmetic.push_back("-");
	arithmetic.push_back("/");
	arithmetic.push_back("*");
	declareImplicitOperator(arithmetic, &PrimitiveType::INT8_TYPE,
			&PrimitiveType::INT8_TYPE, 2);
	declareImplicitOperator(arithmetic, &PrimitiveType::INT32_TYPE,
			&PrimitiveType::INT32_TYPE, 2);
	declareImplicitOperator(arithmetic, &PrimitiveType::FLOAT64_TYPE,
			&PrimitiveType::FLOAT64_TYPE, 2);

	declareImplicitOperator("%", &PrimitiveType::INT8_TYPE,
			&PrimitiveType::INT8_TYPE, 2);
	declareImplicitOperator("%", &PrimitiveType::INT32_TYPE,
			&PrimitiveType::INT32_TYPE, 2);
	declareImplicitOperator("%", &PrimitiveType::FLOAT64_TYPE,
			&PrimitiveType::FLOAT64_TYPE, 2);

	std::vector<std::string> logical;
	logical.push_back("and");
	logical.push_back("or");
	declareImplicitOperator(logical, &PrimitiveType::BOOLEAN_TYPE,
			&PrimitiveType::BOOLEAN_TYPE, 2);

	declareImplicitOperator("not", &PrimitiveType::BOOLEAN_TYPE,
			&PrimitiveType::BOOLEAN_TYPE, 1);

	declareImplicitOperator("-", &PrimitiveType::INT8_TYPE,
			&PrimitiveType::INT8_TYPE, 1);
	declareImplicitOperator("-", &PrimitiveType::INT32_TYPE,
			&PrimitiveType::INT32_TYPE, 1);
	declareImplicitOperator("-", &PrimitiveType::FLOAT64_TYPE,
			&PrimitiveType::FLOAT64_TYPE, 1);

	declareImplicitOperator("~", &PrimitiveType::INT8_TYPE,
			&PrimitiveType::INT8_TYPE, 1);
	declareImplicitOperator("~", &PrimitiveType::INT32_TYPE,
			&PrimitiveType::INT32_TYPE, 1);
	declareImplicitOperator("~", &PrimitiveType::FLOAT64_TYPE,
			&PrimitiveType::FLOAT64_TYPE, 1);
}

void juli::Declarator::declareImplicitOperator(
		const std::vector<std::string> names, const Type* returnType,
		const Type* type, unsigned int arity) {
	for (std::vector<std::string>::const_iterator i = names.begin();
			i != names.end(); ++i) {
		declareImplicitOperator(*i, returnType, type, arity);
	}
}

void juli::Declarator::declareImplicitOperator(const std::string& name,
		const Type* returnType, const Type* type, unsigned int arity) {
	std::vector<FormalParameter> binaryArgs;
	for (unsigned int i = 0; i < arity; ++i) {
		std::stringstream s;
		s << "x" << i;
		binaryArgs.push_back(FormalParameter(type, s.str()));
	}

	Function* f = new Function(name, returnType, binaryArgs, false, 0);
	typeInfo.declareFunction(f);

}

void juli::Declarator::declareImplicitOperator(const std::string& name,
		const Type* type, unsigned int arity) {
	declareImplicitOperator(name, type, type, arity);
}

void juli::Declarator::visit(const Node* n) {
	visitAST<Declarator, void>(*this, n);
}

void juli::Declarator::visitDoubleLiteral(const NLiteral<double>* n) {
}

void juli::Declarator::visitIntegerLiteral(const NLiteral<uint64_t>* n) {
}

void juli::Declarator::visitStringLiteral(const NStringLiteral* n) {
}

void juli::Declarator::visitCharLiteral(const NCharLiteral* n) {
}

void juli::Declarator::visitBooleanLiteral(const NLiteral<bool>* n) {
}

void juli::Declarator::visitVariableRef(const NVariableRef* n) {
}

void juli::Declarator::visitQualifiedAccess(const NQualifiedAccess* n) {
}

void juli::Declarator::visitCast(const NCast* n) {
}

void juli::Declarator::visitUnaryOperator(const NUnaryOperator* n) {
}

void juli::Declarator::visitBinaryOperator(const NBinaryOperator* n) {
}

void juli::Declarator::visitAllocateArray(const NAllocateArray* n) {
}

void juli::Declarator::visitAllocateObject(const NAllocateObject* n) {
}

void juli::Declarator::visitFunctionCall(const NFunctionCall* n) {
}

void juli::Declarator::visitArrayAccess(const NArrayAccess* n) {
}

void juli::Declarator::visitAssignment(const NAssignment* n) {
}

void juli::Declarator::visitBlock(const NBlock* n) {
	StatementList st = n->statements;
	for (StatementList::const_iterator i = st.begin(); i != st.end(); ++i) {
		visit(*i);
	}
}

void juli::Declarator::visitExpressionStatement(const NExpressionStatement* n) {
}

void juli::Declarator::visitVariableDecl(const NVariableDeclaration* n) {
}

void juli::Declarator::visitFunctionDef(const NFunctionDefinition* n) {
	typeInfo.declareFunction(n);
}

void juli::Declarator::visitReturn(const NReturnStatement* n) {
}

void juli::Declarator::visitIf(const NIfStatement* n) {
}

void juli::Declarator::visitWhile(const NWhileStatement* n) {
}

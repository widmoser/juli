#include <iostream>
#include <fstream>

#include <parser/parser.h>
#include <codegen/native.h>


#include <debug/print.h>
#include <parser/ast/node.h>

#include "llvm/ExecutionEngine/ExecutionEngine.h"
#include "llvm/ExecutionEngine/JIT.h"
#include <llvm/ExecutionEngine/GenericValue.h>

#include <llvm/PassManager.h>
#include <llvm/Support/raw_os_ostream.h>
#include <llvm/Support/FormattedStream.h>
#include <llvm/Target/TargetData.h>
#include <llvm/Target/TargetMachine.h>
#include <llvm/Target/TargetLibraryInfo.h>
#include <llvm/Support/TargetSelect.h>
#include <llvm/Support/TargetRegistry.h>
#include <llvm/Support/Program.h>
#include <llvm/Support/PathV1.h>

#include "llvm/Support/Host.h"

//extern NBlock* programBlock;
//extern int yyparse();

using namespace llvm;
using namespace juli;

using std::cerr;

int main(int argc, char **argv) {

	CodeEmitter emitter;
	Parser parser;

	for (int i = 1; i < argc; ++i) {
		std::cout << "Building file: " << argv[i] << std::endl;
		TranslationUnit* unit = parser.parse(argv[i]);
		unit->printStatements(std::cout);
		try {
			unit->generateCode();

			unit->module->dump();

			if (unit->getErrors().empty()) {
				std::string filename(argv[i]);
				std::string basename = filename.substr(0, filename.find_last_of('.', filename.size()));
				filename = basename + ".o";
				emitter.emitCode(filename.c_str(), unit->module);
			} else {
				std::vector<CompilerError> errors = unit->getErrors();
				for (std::vector<CompilerError>::iterator i = errors.begin(); i != errors.end(); ++i) {
					std::cerr << *i;
				}
			}

		} catch (CompilerError& ce) {
			cerr << "Uncaught error: " << ce;
		}

	}

}
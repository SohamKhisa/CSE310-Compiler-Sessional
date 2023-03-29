%{
#include <iostream>
#include <cstdlib>
#include <cstring>
#include <cmath>
#include <fstream>
#include <algorithm>
#include <vector>
#include <cctype>
#include "1705120_SymbolTable.h" 

using namespace std;

int yyparse(void);
int yylex(void);

extern char* yytext;
extern FILE *yyin;
extern int count_line;
extern int count_error;

extern ofstream log_writer, error_writer;

SymbolTable table(30);
vector<SymbolInfo*> paramlist;
string dtype;
bool mainfinish = false, validparam = true;
bool scopeflag = true;				//prevents opening double enter_scop() for function.
string lastcheck;

void yyerror(char *s)
{
	//write your code
	log_writer << "Error at line " << count_line << ": " << s << "\n" << endl;
	error_writer << "Error at line " << count_line << ": " << s << "\n" << endl;
	count_error++;
}


void checkFuncError(string str, Property prop, string purpose, bool params=false)
{
	SymbolInfo *sinfo;
	if(params==false) sinfo = table.lookup(str);
	else sinfo = table.lookupPrevious(str);

	if(sinfo != nullptr) {
		//cout << str << "\t" << sinfo->properties.status << "\t" << purpose << endl;
		if (sinfo->properties.vartype=="function" && sinfo->properties.status=="defined" && purpose=="define") {
			// semantic error for multiple definition of a function
			log_writer << "Error at line " << count_line << ": Multiple definition of the function " << str << "\n" << endl;
			error_writer << "Error at line " << count_line << ": Multiple definition of the function " << str << "\n" << endl;
			count_error++;
		}
		else if (sinfo->properties.vartype == "variable") {
			// semantic error for having a similar function and variable name.
			log_writer << "Error at line " << count_line << ": Multiple declaration of " << str << "\n" << endl;
			error_writer << "Error at line " << count_line << ": Multiple declaration of " << str << "\n" << endl;
			count_error++;
		}
		else if (sinfo->properties.vartype=="function" && sinfo->properties.status=="declared") {
			if(sinfo->properties.datatype != prop.datatype)
			{
				log_writer << "Error at line " << count_line << ": Return type mismatch with function declaration in function " << str << "\n" << endl;
				error_writer << "Error at line " << count_line << ": Return type mismatch with function declaration in function " << str << "\n" << endl;
				count_error++;
			}
			if(sinfo->properties.list.size() != paramlist.size()) {
				log_writer << "Error at line " << count_line << ": Total number of arguments mismatch with declaration in function " << str << "\n" << endl;
				error_writer << "Error at line " << count_line << ": Total number of arguments mismatch with declaration in function " << str << "\n" << endl;
				count_error++;
			}
		}
	}
	else {
		int cnt;
		cnt = 1;
		for(auto i=paramlist.begin(); i!=paramlist.end(); i++) {
			if((*i)->getName().empty()) {
				validparam = false;
				if(purpose=="define") {
					log_writer << "Error at line " << count_line << ": " << cnt << "th parameter's name not given in function definition of " << str << "\n" << endl;
					error_writer << "Error at line " << count_line << ": " << cnt << "th parameter's name not given in function definition of " << str << "\n" << endl;
					count_error++;
					break;
				}
				else if(purpose=="declare") {
					log_writer << "Error at line " << count_line << ": " << cnt << "th parameter's name not given in function definition of " << str << "\n" << endl;
					error_writer << "Error at line " << count_line << ": " << cnt << "th parameter's name not given in function definition of " << str << "\n" << endl;
					count_error++;
					break;
				}
			}
			cnt++;
		}
	}
}


void insertFunction(string name, string type, string datatype, bool params) {
	SymbolInfo *si = new SymbolInfo(name, type);
	Property prop;
	prop.datatype = datatype;
	prop.isarray = false;
	prop.vartype = "function";
	prop.status = "defined";
	for (auto i=paramlist.begin(); i!=paramlist.end(); i++) {
		prop.list.push_back((*i));
	}
	si->properties = prop;

	int num;
	num = 0;
	
	SymbolInfo *sinfo;
	if(params==false) sinfo = table.lookup(name);
	else sinfo = table.lookupPrevious(name);

	if(sinfo!=nullptr) {
		if(sinfo->properties.vartype=="function" && sinfo->properties.status=="declared" && sinfo->properties.list.size()==paramlist.size()) {
			if(params==false)	table.reMove(name);
			else if(params==true)	table.removePrevious(name);
		}
	}

	//cout << si->getName() << "\t" << si->getType() << "\t" << si->properties.status << endl;
	if(params==false) {													// || (params==true && validparam==false)
		table.inSert(si->getName(), si->getType(), si->properties);
		validparam = true;
	}
	else if(params==true) {														// && paramlist.size() > num
		bool v = table.insertPrevious(si->getName(), si->getType(), si->properties);
	}
	paramlist.clear();
}



int parseInt(string str)
{
    int num = 0;
	for (int i=0; i<str.size(); i++) {
		char c = str[i];
		int t = c-'0';
		num = num*10 + t;
	}
	return num;
}

%}

%union {
	SymbolInfo *info;
	vector<SymbolInfo*> *list;
}


%token IF ELSE FOR WHILE DO BREAK DOUBLE INT FLOAT CHAR VOID RETURN COMMA SEMICOLON 
%token SWITCH CASE DEFAULT CONTINUE ASSIGNOP INCOP DECOP NOT LPAREN RPAREN
%token LCURL RCURL LTHIRD RTHIRD COMMENT PRINTLN
%token <info> CONST_INT
%token <info> CONST_FLOAT
%token <info> CONST_CHAR 
%token <info> STRING
%token <info> ID
%token <info> ADDOP
%token <info> MULOP
%token <info> RELOP
%token <info> LOGICOP

%type <info> arguments logic_expression argument_list factor variable expression unary_expression term simple_expression rel_expression var_declaration compound_statement type_specifier declaration_list unit func_declaration statement statements expression_statement func_definition program parameter_list
//left
//right
%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE
%nonassoc LOWER_THAN_ID
%nonassoc ID

%%

start: program
	{
		//write your code in this block in all the similar blocks below
		log_writer << "Line " << count_line << ": start : program" << endl << endl;
		table.print_alltable(log_writer);
		log_writer << "\nTotal lines: " << count_line << endl;
		log_writer << "Total errors: " << count_error << endl;
		log_writer << endl;
	}
	;

program: program unit {
						log_writer << "Line " << count_line << ": program : program unit" << endl << endl;
						string progunit = $1->getName() + $2->getName();
						log_writer << progunit << endl << endl;
						SymbolInfo *si = new SymbolInfo(progunit, "program");
						$$ = si;
					}
	| unit	{
						log_writer << "Line " << count_line << ": program : unit" << endl << endl;
						log_writer << $1->getName() << endl << endl;
		}
	;
	
unit: var_declaration	{ 
						log_writer << "Line " << count_line << ": unit : var_declaration" << endl << endl;
						log_writer << $1->getName() << endl << endl;
					}
     | func_declaration {
		 				log_writer << "Line " << count_line << ": unit : func_declaration" << endl << endl;
						log_writer << $1->getName() << endl << endl;
	 				}
     | func_definition {
		 				log_writer << "Line " << count_line << ": unit : func_definition" << endl << endl;
						
						// here changed $$ = $1 is replaced by $$ = sym
						string logtext = $1->getName() + "\n";
						// SymbolInfo *sym = new SymbolInfo($1->getName(), $1->getType());
						// sym->properties = $1->properties;
						// $$ = sym;
						$1->setName(logtext);
						
						log_writer << $1->getName() << endl << endl;

	 				}
     ;
     
func_declaration: type_specifier ID LPAREN parameter_list RPAREN{string s=$2->getName(); Property p=$1->properties; checkFuncError(s,p,"declare",true);} SEMICOLON {
						table.exit_scop();
						log_writer << "Line " << count_line << ": func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON\n" << endl;
						
						Property prop;
						prop.datatype = $1->properties.datatype;
						prop.isarray = false;
						prop.vartype = "function";
						prop.status = "declared";
						for (auto i=paramlist.begin(); i!=paramlist.end(); i++) {
							prop.list.push_back((*i));
						}

						int num;
						num = 0;
						if(paramlist.size() > num) {
							table.inSert($2->getName(), "ID", prop);
						}
						paramlist.clear();
						
						string funcdec = $1->getName() + " " + $2->getName() + "(" + $4->getName() + ")" + ";\n";
						log_writer << funcdec << endl << endl;
						
						SymbolInfo *si = new SymbolInfo(funcdec, "func_declaration");
						si->properties.datatype = $1->properties.datatype;
						$$ = si;

						scopeflag = true;
					}
				| type_specifier ID LPAREN RPAREN{ string s=$2->getName(); Property p=$1->properties; checkFuncError(s,p,"declare"); table.enter_scop(); } SEMICOLON {
						table.exit_scop();
						log_writer << "Line " << count_line << ": func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON\n" << endl;
						
						Property prop;
						prop.datatype = $1->properties.datatype;
						prop.isarray = false;
						prop.vartype = "function";
						prop.status = "declared";
						
						table.inSert($2->getName(), "ID", prop);
						string funcdec = $1->getName() + " " + $2->getName() + "(" + ")" + ";\n";
						log_writer << funcdec << endl << endl;
						
						SymbolInfo *si = new SymbolInfo(funcdec, "func_declaration");
						si->properties.datatype = $1->properties.datatype;
						$$ = si;
					}
		;
		 
func_definition: type_specifier ID LPAREN parameter_list RPAREN{string n=$2->getName(), t=$2->getType(), d=$1->properties.datatype; Property p=$1->properties; checkFuncError(n,p,"define",true); insertFunction(n,t,d,true);} compound_statement {

						//Have to catch the semantic error: type_specifier void and return
						
						table.print_currtable(log_writer);
						table.exit_scop();

						//Have to check if the function ID has been previously defined.
						//As we are not allowing to functions of the same name.
						//If it is we have to check the parameters.
						//If the parameters are also same then we have to define this as an error.
						//Otherwise insert the function ID in the SymbolTable and printall


						table.print_alltable(log_writer);
						
						log_writer << "\nLine " << count_line << ": func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement" << endl << endl;
						
						string logtext = $1->getName() + " " + $2->getName() + "(" + $4->getName() + ")";
						logtext += $7->getName();
						log_writer << logtext << endl << endl;
						
						SymbolInfo *sym = new SymbolInfo(logtext, "func_definition");
						sym->properties.datatype = $1->properties.datatype;
						$$ = sym;

						lastcheck = logtext;
						if($2->getName() == "main")
							mainfinish = true;

					}
		| type_specifier ID LPAREN RPAREN{ string n=$2->getName(), t=$2->getType(), d=$1->properties.datatype; Property p=$1->properties; checkFuncError(n,p,"define"); insertFunction(n,t,d,false);} compound_statement %prec LOWER_THAN_ID {
						table.print_currtable(log_writer);
						table.exit_scop();

						table.print_alltable(log_writer);

						string logtext = $1->getName() + " " + $2->getName() + "(" + ")" + $6->getName();
						log_writer << "\nLine " << count_line << ": func_definition : type_specifier ID LPAREN RPAREN compound_statement\n" << endl;
						log_writer << logtext << endl << endl;

						SymbolInfo *sym = new SymbolInfo(logtext, "func_definition");
						sym->properties.datatype = $1->properties.datatype;
						$$ = sym;

						lastcheck = logtext;
						if($2->getName() == "main")
							mainfinish = true;
					}
 		;				


parameter_list: parameter_list COMMA type_specifier ID {
						SymbolInfo *si = new SymbolInfo($4->getName(), $4->getType());
						si->properties.datatype = $3->properties.datatype;
						si->properties.vartype = "parameter";

						bool v = table.inSert(si->getName(), si->getType(), si->properties);
						if(v == false) {
							log_writer << "Error at line " << count_line << ": Multiple declaration of a in parameter\n" << endl;
							error_writer << "Error at line " << count_line << ": Multiple declaration of a in parameter\n" << endl;
							count_error++;
						}

						log_writer << "Line " << count_line << ": parameter_list : parameter_list COMMA type_specifier ID\n" << endl;

						string plist = $1->getName() + "," + $3->getName() + " " + $4->getName();
						log_writer << plist << endl << endl;
						
						paramlist.push_back(si);
						
						// here changed $$ = $1 is replaced by $$=sym;
						// SymbolInfo *sym = new SymbolInfo(plist, $1->getType());
						// sym->properties = $1->properties;
						// $$ = sym;

						$1->setName(plist);
					}
				| parameter_list COMMA type_specifier {
						/*this has to be implemented*/
						log_writer << "Line " << count_line << ": parameter_list : parameter_list COMMA type_specifier\n" << endl;
						
						string logtext = $1->getName() + "," + $3->getName();
						log_writer << logtext << endl << endl;

						//log_writer << "Error at line " << count_line << ": syntax error\n" << endl;
						string type = $3->getType();
						SymbolInfo *si = new SymbolInfo("", type);
						si->properties.vartype = "parameter";
						si->properties.datatype = $3->properties.datatype;
						paramlist.push_back(si);

						//here changed $$ = $1 is replaced by $$ = sym
						// SymbolInfo *sym = new SymbolInfo(logtext, "");
						// sym->properties = $1->properties;
						// $$ = sym;
						$1->setName(logtext);
					}
 				| type_specifier ID {
					 	table.enter_scop();
						scopeflag = false;
						SymbolInfo *si = new SymbolInfo($2->getName(), $2->getType());
						si->properties.datatype = $1->properties.datatype;
						si->properties.vartype = "parameter";
						table.inSert(si->getName(), si->getType(), si->properties);

				 		log_writer << "Line " << count_line << ": parameter_list : type_specifier ID" << endl << endl;
						string plist = $1->getName() + " " + $2->getName();
						log_writer << plist << endl << endl;
						
						paramlist.push_back(si);
						
						SymbolInfo *sym = new SymbolInfo(plist, "parameter_list");
						$$ = sym;
		 			}
		| type_specifier {
						table.enter_scop();
						scopeflag = false;
						/*this has to be implemented*/
						log_writer << "Line " << count_line << ": parameter_list : type_specifier\n" << endl;

						string logtext = $1->getName();
						log_writer << logtext << endl << endl;

						//log_writer << "Error at line " << count_line << ": syntax error\n" << endl;
						count_error++;

						string type = $1->getType();
						SymbolInfo *si = new SymbolInfo("", type);
						si->properties.vartype = "parameter";
						si->properties.datatype = $1->properties.datatype;
						paramlist.push_back(si);

						// here changed $$ = $1 is replaced by $$ = sym;
						SymbolInfo *sym = new SymbolInfo(logtext, $1->getType());
						sym->properties = $1->properties;
						$$ = sym;

						lastcheck = $1->getName();
					}
	    | error {
						log_writer << lastcheck << endl << endl;
						SymbolInfo *si = new SymbolInfo(lastcheck, "");
						$$ = si;
					}
 		;


compound_statement: LCURL{if(scopeflag) {table.enter_scop();} scopeflag=true;} statements RCURL {
						log_writer << "Line " << count_line << ": compound_statement : LCURL statements RCURL\n" << endl;
						string comstate = "{\n" + $3->getName() + "}\n";
						log_writer << comstate << endl << endl;
						SymbolInfo *si = new SymbolInfo(comstate, "compound_statement");
						$$ = si;
					}
 		    | LCURL{if(scopeflag) {table.enter_scop();} scopeflag=true;} RCURL {
				 		log_writer << "Line " << count_line << ": compound_statement : LCURL RCURL\n" << endl;
						string comstate = "{}\n";
						log_writer << comstate << endl << endl;
						SymbolInfo *si = new SymbolInfo(comstate, "compound_statement");
						$$ = si;
			 		}
			| ID{yyerror("syntax error");log_writer << $1->getName() << endl << endl;} LCURL{if(scopeflag) {table.enter_scop();} scopeflag=true;} statements RCURL {
						log_writer << "Line " << count_line << ": compound_statement : LCURL statements RCURL\n" << endl;
						string comstate = "{\n" + $5->getName() + "}\n";
						log_writer << comstate << endl << endl;
						SymbolInfo *si = new SymbolInfo(comstate, "compound_statement");
						$$ = si;
					}
			| ADDOP{yyerror("syntax error");log_writer << $1->getName() << endl << endl;} LCURL{if(scopeflag) {table.enter_scop();} scopeflag=true;} statements RCURL {
						log_writer << "Line " << count_line << ": compound_statement : LCURL statements RCURL\n" << endl;
						string comstate = "{\n" + $5->getName() + "}\n";
						log_writer << comstate << endl << endl;
						SymbolInfo *si = new SymbolInfo(comstate, "compound_statement");
						$$ = si;
					}
			| MULOP{yyerror("syntax error");log_writer << $1->getName() << endl << endl;} LCURL{if(scopeflag) {table.enter_scop();} scopeflag=true;} statements RCURL {
						log_writer << "Line " << count_line << ": compound_statement : LCURL statements RCURL\n" << endl;
						string comstate = "{\n" + $5->getName() + "}\n";
						log_writer << comstate << endl << endl;
						SymbolInfo *si = new SymbolInfo(comstate, "compound_statement");
						$$ = si;
					}
 		    ;
 		    
var_declaration: type_specifier declaration_list SEMICOLON {
						log_writer << "Line " << count_line << ": var_declaration : type_specifier declaration_list SEMICOLON\n"<< endl;
						
						string spectype = $1->properties.datatype;
						if(spectype == "void") {
							log_writer << "Error at line " << count_line << ": Variable type cannot be void\n" << endl;
							error_writer << "Error at line " << count_line << ": Variable type cannot be void\n" << endl;
							count_error++;
						}

						string vardec = $1->getName() + " " + $2->getName() + ";\n";
						log_writer << vardec << endl;
						SymbolInfo *si = new SymbolInfo(vardec, "var_declaration");
						$$ = si;

						lastcheck = vardec;
					}
 		 ;
 		 
type_specifier: INT { 
						log_writer << "Line " << count_line << ": type_specifier : INT" << endl << endl;
						log_writer << "int" << endl << endl;
						SymbolInfo *si = new SymbolInfo("int", "INT");
						si->properties.datatype = "int";
						dtype = "int";
						$$ = si;
					}
 				| FLOAT {
					 	log_writer << "Line " << count_line << ": type_specifier : FLOAT\n" << endl;
						log_writer << "float\n" << endl;
						SymbolInfo *si = new SymbolInfo("float", "FLOAT");
						si->properties.datatype = "float";
						dtype = "float";
						$$ = si;
		 			}
 				| VOID {
					 	log_writer << "Line " << count_line << ": type_specifier : VOID\n" << endl;
						log_writer << "void\n" << endl;
						SymbolInfo *si = new SymbolInfo("void", "VOID");
						si->properties.datatype = ("void");
						dtype = "void";
						$$ = si;
				 	}
 		;
 		
declaration_list: declaration_list COMMA ID {
						Property prop;
						prop.datatype = dtype;
						prop.isarray = false;
						prop.vartype = "variable";
						// which error is dependent on which error has to be checked.
						if(dtype != "void") {
							// void type variable error;
							bool isin = table.inSert($3->getName(), "ID", prop);
							if(isin == false) {
								string idname = $3->getName();
								log_writer << "Error at line " << count_line << ": Multiple declaration of " << idname << "\n" << endl;
								error_writer << "Error at line " << count_line << ": Multiple declaration of " << idname << "\n" << endl;
								count_error++;
							}
						}
						
						log_writer << "Line " << count_line << ": declaration_list : declaration_list COMMA ID" << endl << endl;
						string declist = $1->getName() + "," + $3->getName();
						log_writer << declist << endl << endl;
						SymbolInfo *si = new SymbolInfo(declist, "declaration_list");
						si->properties.datatype = $1->properties.datatype;
						$$ = si;

						lastcheck = $3->getName();
					}
 		  		| declaration_list COMMA ID LTHIRD CONST_INT RTHIRD {
					   	Property prop;
						prop.datatype = dtype;
						prop.isarray = true;
						prop.vartype = "variable";
						prop.arraysize = parseInt($5->getName());
						
						// which error is depended on which error has to be checked.
						if(dtype != "void") {
							// void type variable error;
							bool isin = table.inSert($3->getName(), "ID", prop);
							if(isin == false) {
								string idname = $3->getName();
								log_writer << "Error at line " << count_line << ": Multiple declaration of " << idname << "\n" << endl;
								error_writer << "Error at line " << count_line << ": Multiple declaration of " << idname << "\n" << endl;
								count_error++;
							}
						}

						log_writer << "Line " << count_line << ": declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD\n" << endl;
						string declist = $1->getName() + "," + $3->getName() + "[" + $5->getName() + "]";
						log_writer << declist << endl << endl;
						SymbolInfo *si = new SymbolInfo(declist, "declaration_list");
						si->properties.datatype = $1->properties.datatype;
						$$ = si;

						lastcheck = $3->getName() + "[" + $5->getName() + "]";
					}
 		  		| ID {
						Property prop;
						prop.datatype = dtype;
						prop.isarray = false;
						prop.vartype = "variable";
						
						if(dtype != "void") {
							// void type variable error;
							bool isin = table.inSert($1->getName(), "ID", prop);
							if(isin == false) {
								string idname = $1->getName();
								log_writer << "Error at line " << count_line << ": Multiple declaration of " << idname << "\n" << endl;
								error_writer << "Error at line " << count_line << ": Multiple declaration of " << idname << "\n" << endl;
								count_error++;
							}
						}

						log_writer << "Line " << count_line << ": declaration_list : ID" << endl << endl;
						log_writer << $1->getName() << endl << endl;

						SymbolInfo *si = new SymbolInfo($1->getName(), "ID");
						si->properties.datatype = $1->properties.datatype;
						$$ = si;

						lastcheck = $1->getName();
					}
 		  		| ID LTHIRD CONST_INT RTHIRD {
						log_writer << "Line " << count_line << ": declaration_list : ID LTHIRD CONST_INT RTHIRD\n" << endl;
						string logtext = $1->getName() + "[" + $3->getName() + "]";
						
						Property prop;
						prop.datatype = dtype;
						prop.isarray = true;
						prop.vartype = "variable";
						prop.arraysize = parseInt($3->getName());
						
						if(dtype!="void") {
							bool isin = table.inSert($1->getName(), $1->getType(), prop);
							if(isin == false) {
								string idname = $1->getName();
								log_writer << "Error at line " << count_line << ": Multiple declaration of " << idname << "\n" << endl;
								error_writer << "Error at line " << count_line << ": Multiple declaration of " << idname << "\n" << endl;
								count_error++;
							}
						}

						log_writer << logtext << endl << endl;
						SymbolInfo *si = new SymbolInfo(logtext, "declaration_list");
						si->properties.datatype = $1->properties.datatype;
						$$ = si;

						lastcheck = logtext;
				   }
				| error {
						log_writer << lastcheck << endl << endl;
						SymbolInfo *si = new SymbolInfo(lastcheck, "");
						$$ = si;
					}
 		  ;
 		  
statements: statement {
						log_writer << "Line " << count_line << ": statements : statement\n" << endl;
						log_writer << $1->getName() << endl << endl;
						SymbolInfo *si = new SymbolInfo($1->getName(), "statements");
						si->properties.datatype = $1->properties.datatype;
						$$ = si;
					}
	   | statements statement {
		   				log_writer << "Line " << count_line << ": statements : statements statement\n" << endl;
						string logtext = $1->getName() + $2->getName();
						log_writer << logtext << endl << endl;

						//here changed $$ = $1 is replaced by $$ = sym
						// SymbolInfo *sym = new SymbolInfo(logtext, $1->getType());
						// sym->properties = $1->properties;
						// $$ = sym;

						$1->setName(logtext);
	   				}
	   | error {
						log_writer << lastcheck << endl << endl;
						SymbolInfo *si = new SymbolInfo(lastcheck, "");
						$$ = si;
					}
	   ;
	   
statement: var_declaration {
						log_writer << "Line " << count_line << ": statement : var_declaration\n" << endl;
						log_writer << $1->getName() << endl << endl;
					}
	  | expression_statement {
		  				log_writer << "Line " << count_line << ": statement : expression_statement\n" << endl;
						
						//here changed $$ = $1 is replaced by $$ = sym
						string logtext = $1->getName()+"\n";
						// SymbolInfo *sym = new SymbolInfo(logtext, $1->getType());
						// sym->properties = $1->properties;
						// $$ = sym;
						$1->setName(logtext);
						log_writer << $1->getName() << endl << endl;
	  				}
	  | compound_statement {
		  				string comstate = $1->getName();
		  				if(scopeflag) {
							  table.print_currtable(log_writer);
							  table.exit_scop();
							  comstate += "\n";
						}
		  				table.print_alltable(log_writer);
		  				log_writer << "\nLine " << count_line << ": statement : compound_statement\n" << endl;
						log_writer << comstate << endl;
	  				}
	  | FOR LPAREN expression_statement expression_statement expression RPAREN statement {
		  				log_writer << "Line " << count_line << ": statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement\n" << endl;
						
						string stmnt = $7->getName();
						stmnt.erase(stmnt.begin());
						string logtext = "for(" + $3->getName() + $4->getName() + $5->getName() + "){" + stmnt;
						log_writer << logtext << endl << endl;

						SymbolInfo *si = new SymbolInfo(logtext, "statemnet");
						$$ = si;
	  				}
	  | IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE {
		  				log_writer << "Line " << count_line << ": statement : IF LPAREN expression RPAREN statement\n" << endl;
						  
						string stmnt = $5->getName(); 
						//removing the first element that is {
						stmnt.erase(stmnt.begin());

						string logtext = "if (" + $3->getName() + "){" + stmnt;
						log_writer << logtext << endl << endl;

						SymbolInfo *si = new SymbolInfo(logtext, "statement");
						$$ = si;
	  				}
	  | IF LPAREN expression RPAREN statement ELSE statement {
		  				log_writer << "Line " << count_line << ": statement : IF LPAREN expression RPAREN statement ELSE statement\n" << endl;
						string stmnt = $5->getName();
						//removing the first element that is {
						stmnt.erase(stmnt.begin());

						string logtext = "if (" + $3->getName() + "){" + stmnt + "else\n" + $7->getName();
						log_writer << logtext << endl << endl;

						SymbolInfo *si = new SymbolInfo(logtext, "statement");
						$$ = si;
	  				}
	  | WHILE LPAREN expression RPAREN statement {
		  				log_writer << "Line " << count_line << ": statement : WHILE LPAREN expression RPAREN statement\n" << endl;
						string stmnt = $5->getName();
						//removing the first element that is {
						stmnt.erase(stmnt.begin());

						string logtext = "while (" + $3->getName() + "){" + stmnt;
						log_writer << logtext << endl << endl;

						SymbolInfo *si = new SymbolInfo(logtext, "statement");
						$$ = si;
	  				}
	  | PRINTLN LPAREN ID RPAREN SEMICOLON {
		  				log_writer << "Line " << count_line << ": statement : PRINTLN LPAREN ID RPAREN SEMICOLON\n" << endl;
						
						SymbolInfo *si = table.lookup($3->getName());
						if(si == nullptr) {
							string idname = $3->getName();
							log_writer << "Error at line " << count_line << ": Undeclared variable " << idname << "\n" << endl;
							error_writer << "Error at line " << count_line << ": Undeclared variable " << idname << "\n" << endl;
							count_error++;
						}

						string stmnt = "printf(" + $3->getName() + ");\n";
						log_writer << stmnt << endl << endl;
						
						si = new SymbolInfo(stmnt, "statement");
						$$ = si;
	  				}
	  | RETURN expression SEMICOLON {
		  				log_writer << "Line " << count_line << ": statement : RETURN expression SEMICOLON\n" << endl;
						
						string stmnt = "return " + $2->getName() + ";\n";
						log_writer << stmnt << endl << endl;
						
						SymbolInfo *si = new SymbolInfo(stmnt, "statement");
						si->properties.datatype = $2->properties.datatype;
						$$ = si;
	  				}
	  ;
	  
expression_statement: SEMICOLON	{
						log_writer << "Line " << count_line << ": expression_statement : SEMICOLON\n" << endl;
						log_writer << ";" << endl << endl;
						SymbolInfo *si = new SymbolInfo(";", "expression_statement");
						$$ = si;
					}		
			| expression SEMICOLON {
						log_writer << "Line " << count_line << ": expression_statement : expression SEMICOLON" << endl << endl;
						string logtext = $1->getName() + ";";
						log_writer << logtext << endl << endl;
						
						//here changed $$ = $1 is replaced by $$ = sym
						// SymbolInfo *sym = new SymbolInfo(logtext, $1->getType());
						// sym->properties = $1->properties;
						// $$ = sym;
						$1->setName(logtext);
					}
			;
	  
variable: ID {
						log_writer << "Line " << count_line << ": variable : ID\n" << endl;
						
						SymbolInfo *sym = table.lookup($1->getName());
						string datype;
						// Need to handle the precedence of errors.
						if(sym == nullptr) {
							string idname = $1->getName();
							log_writer << "Error at line " << count_line << ": Undeclared variable " << idname << "\n" << endl;
							error_writer << "Error at line " << count_line << ": Undeclared variable " << idname << "\n" << endl;
							count_error++;
						}
						else {
							dtype = sym->properties.datatype;
							if(sym->properties.isarray == true) {
								log_writer << "Error at line " << count_line << ": Type mismatch, " << sym->getName() << " is an array\n" << endl;
								error_writer << "Error at line " << count_line << ": Type mismatch, " << sym->getName() << " is an array\n" << endl;
								count_error++;
							}
						}

						log_writer << $1->getName() << endl << endl;
						SymbolInfo *si = new SymbolInfo($1->getName(), "variable");
						si->properties.datatype = dtype;
						$$ = si;
		}
	 	| ID LTHIRD expression RTHIRD {
			 			SymbolInfo *sym = table.lookup($1->getName());
						string dtype;

						log_writer << "Line " << count_line << ": variable : ID LTHIRD expression RTHIRD\n" << endl;

						if(sym == nullptr) {
							// errror handle no such variable declared. Also, handle the print serial.
							// whether the next error comes after this one.
							// if this error occurs.
							string idname = $1->getName();
							log_writer << "Error at line " << count_line << ": Undeclared variable " << idname << "\n" << endl;
							error_writer << "Error at line " << count_line << ": Undeclared variable " << idname << "\n" << endl;
							count_error++;
						}
						else {
							dtype = sym->properties.datatype;
							if(!sym->properties.isarray) {
								string varName = $1->getName();
								log_writer << "Error at line " << count_line << ": " << varName << " not an array\n" << endl;
								error_writer << "Error at line " << count_line << ": " << varName << " not an array\n" << endl;
								count_error++;
							}						
						}
						
						string isint = $3->properties.datatype;
						if(isint != "int") {
							log_writer << "Error at line " << count_line << ": Expression inside third brackets not an integer\n" << endl;
							error_writer << "Error at line " << count_line << ": Expression inside third brackets not an integer\n" << endl;
							count_error++;
						}

						string logtext = $1->getName() + "[" + $3->getName() + "]";
						log_writer << logtext << endl << endl;
						SymbolInfo *si = new SymbolInfo(logtext, "variable");
						si->properties.datatype = dtype;
						$$ = si;
		 			}
	;
	 
 expression: logic_expression {
	 					log_writer << "Line " << count_line << ": expression : logic expression\n" << endl;
						log_writer << $1->getName() << endl << endl;
						SymbolInfo *si = new SymbolInfo($1->getName(), "expression");
						si->properties.datatype = $1->properties.datatype;
						$$ = si;
 					}
	   | variable ASSIGNOP logic_expression {
						log_writer << "Line " << count_line << ": expression : variable ASSIGNOP logic_expression\n" << endl;

						string vartype = $1->properties.datatype;
						string logictype = $3->properties.datatype;

						if(logictype == "void") {
							log_writer << "Error at line " << count_line << ": Void function used in expression\n" << endl;
							error_writer << "Error at line " << count_line << ": Void function used in expression\n" << endl;
							count_error++;
						}
						if((vartype=="int" && logictype=="float") && (!vartype.empty() && !logictype.empty())) {
							log_writer << "Error at line " << count_line << ": Type Mismatch\n" << endl;
							error_writer << "Error at line " << count_line << ": Type Mismatch\n" << endl;
							count_error++;
						}
						
						string logtext = $1->getName() + "=" + $3->getName();
						log_writer << logtext << endl << endl;
						SymbolInfo *si = new SymbolInfo(logtext, "expression");
						$$ = si;
	   				}
	   ;
			
logic_expression: rel_expression {
						log_writer << "Line " << count_line << ": logic_expression : rel_expression\n" << endl;
						log_writer << $1->getName() << endl << endl;
						SymbolInfo *si = new SymbolInfo($1->getName(), "logic_expression");
						si->properties.datatype = $1->properties.datatype;
						$$ = si;
					}
		 | rel_expression LOGICOP rel_expression {
			 			log_writer << "Line " << count_line << ": logic_expression : rel_expression LOGICOP rel_expression\n" << endl;
						
						string logtext = $1->getName() + $2->getName() + $3->getName();
						log_writer << logtext << endl << endl;
						
						SymbolInfo *si = new SymbolInfo(logtext, "logic_expression");
						string firstype = $1->properties.datatype;
						string thirdtype = $3->properties.datatype;
						si->properties.datatype = "int";
						$$ = si;
		 			}
		 ;
			
rel_expression: simple_expression	{
						log_writer << "Line " << count_line << ": rel_expression : simple_expression\n" << endl;
						log_writer << $1->getName() << endl << endl;
						SymbolInfo *si = new SymbolInfo($1->getName(), "rel_expression");
						si->properties.datatype = $1->properties.datatype;
						$$ = si;
					}
		| simple_expression RELOP simple_expression	{
						log_writer << "Line " << count_line << ": rel_expression : simple_expression RELOP simple_expression\n" << endl;
						string logtext = $1->getName() + $2->getName() + $3->getName();
						log_writer << logtext << endl << endl;
						SymbolInfo *si = new SymbolInfo(logtext, "rel_expression");
						
						string firstype = $1->properties.datatype;
						string thirdtype = $3->properties.datatype;
						si->properties.datatype = "int";
						$$ = si;
					}
		;
				
simple_expression: term {
						log_writer << "Line " << count_line << ": simple_expression : term\n" << endl;
						log_writer << $1->getName() << endl << endl;
						SymbolInfo *si = new SymbolInfo($1->getName(), "simple_expression");
						si->properties.datatype = $1->properties.datatype;
						$$ = si;
					}
		  | simple_expression ADDOP term {
			  			log_writer << "Line " << count_line << ": simple_expression : simple_expression ADDOP term" << endl << endl;
						string simpex = $1->getName() + $2->getName() + $3->getName();
						log_writer << simpex << endl << endl;
						SymbolInfo *si = new SymbolInfo(simpex, "simple_expression");
						
						string termtype = $3->properties.datatype;
						string simtype = $1->properties.datatype;
						
						if(termtype=="float")	si->properties.datatype = $3->properties.datatype;
						else if(simtype=="float")	si->properties.datatype = $1->properties.datatype;
						else	si->properties.datatype = $1->properties.datatype;
						$$ = si;
		  			}
		  ;
					
term:	unary_expression {
						log_writer << "Line " << count_line << ": term : unary_expression\n" << endl;
						log_writer << $1->getName() << endl << endl;
						SymbolInfo *si = new SymbolInfo($1->getName(), "term");
						si->properties.datatype = $1->properties.datatype;
						$$ = si;
					}
     |  term MULOP unary_expression {
		 				log_writer << "Line " << count_line << ": term : term MULOP unary_expression\n" << endl;
						
						string termtype = $1->properties.datatype;
						string uextype = $3->properties.datatype;
						string uexName = $3->getName();
						string sign = $2->getName();
						if((termtype!="int" || uextype!="int") && sign=="%") {
							log_writer << "Error at line " << count_line << ": Non-Integer operand on modulus operator\n" << endl;
							error_writer << "Error at line " << count_line << ": Non-Integer operand on modulus operator\n" << endl;
							count_error++;
						}
						if(uexName == "0") {
							log_writer << "Error at line " << count_line << ": Modulus by Zero\n" << endl;
							error_writer << "Error at line " << count_line << ": Modulus by Zero\n" << endl;
							count_error++;
						}
						if(uextype == "void") {
							log_writer << "Error at line " << count_line << ": Void function used in expression\n" << endl;
							error_writer << "Error at line " << count_line << ": Void function used in expression\n" << endl;
							count_error++;
						}
						
						string logtext = $1->getName() + $2->getName() + $3->getName();
						log_writer << logtext << endl << endl;
						
						SymbolInfo *si = new SymbolInfo(logtext, "term");
						uextype = $3->properties.datatype;

						string thirtype = $3->properties.datatype;
						string firstype = $1->properties.datatype;
						
						if(sign=="%")			si->properties.datatype = "int";
						else if(thirtype=="float")	si->properties.datatype = $3->properties.datatype;
						else if(firstype=="float")	si->properties.datatype = $1->properties.datatype;
						else	si->properties.datatype = $1->properties.datatype;
						$$ = si;
	 				}
     ;

unary_expression: ADDOP unary_expression {
						log_writer << "Line " << count_line << ": unary_expression : ADDOP unary_expression\n" << endl;

						string adex = $1->getName() + $2->getName();
						log_writer << adex << endl << endl;

						SymbolInfo *si = new SymbolInfo(adex, $2->getType());
						si->properties.datatype = $2->properties.datatype;

						$$ = si;
					}
		 | NOT unary_expression {
			 			log_writer << "Line " << count_line << ": unary_expression : NOT unary expression\n" << endl;
						
						string notex = "!" + $2->getName();
						log_writer << notex << endl << endl;

						SymbolInfo *si = new SymbolInfo(notex, $2->getType());
						si->properties.datatype = $2->properties.datatype;

						$$ = si;
					}
		 | factor {
			 			log_writer << "Line " << count_line << ": unary_expression : factor" << endl << endl;
						log_writer << $1->getName() << endl << endl;
						SymbolInfo *si = new SymbolInfo($1->getName(), "unary_expression");
						si->properties.datatype = $1->properties.datatype;
						$$ = si;
		 		}
		 ;
	
factor: variable {
						log_writer << "Line " << count_line << ": factor : variable\n" << endl;
						log_writer << $1->getName() << endl << endl;
						SymbolInfo *si = new SymbolInfo($1->getName(), "factor");
						si->properties.datatype = $1->properties.datatype;
						$$ = si;
				}
	| ID LPAREN argument_list RPAREN {
						log_writer << "Line " << count_line << ": factor : ID LPAREN argument_list RPAREN\n"<< endl;
						
						string funcName = $1->getName();
						SymbolInfo *sinfo = table.lookup(funcName);
						if(sinfo != nullptr) {
							vector<SymbolInfo*> vid = sinfo->properties.list;
							vector<SymbolInfo*> varg = $3->properties.list;

							if(sinfo->properties.vartype=="function") {
								if(vid.size() != varg.size()) {
									// semantic error for argument size not equal to parameter size.
									log_writer << "Error at line " << count_line << ": Total number of arguments mismatch in function " << funcName << "\n" << endl;
									error_writer << "Error at line " << count_line << ": Total number of arguments mismatch in function " << funcName << "\n" << endl;
									count_error++;
								}
								else {
									int count;
									count = 1;
									for(auto i=vid.begin(),j=varg.begin(); i!=vid.end(); i++,j++) {
										if(((*i)->properties.datatype!="float") && ((*i)->properties.datatype != (*j)->properties.datatype)) {
											log_writer << "Error at line " << count_line << ": " << count << "th argument mismatch in function " << funcName << "\n" << endl;
											error_writer << "Error at line " << count_line << ": " << count << "th argument mismatch in function " << funcName << "\n" << endl;
											count_error++;
											break;
										}
										count++;
									}
								}
							}
							else {
								log_writer << "Error at line " << count_line << ": " << funcName << " is not a function\n" << endl;
								error_writer << "Error at line " << count_line << ": " << funcName << " is not a function\n" << endl;
								count_error++;
							}

							string logtext = $1->getName() + "(" + $3->getName() + ")";
							log_writer << logtext << endl << endl;
							SymbolInfo *si = new SymbolInfo(logtext, "factor");
							si->properties.datatype = sinfo->properties.datatype;
							$$ = si;
						}
						else {
							log_writer << "Error at line " << count_line << ": Undeclared function " << funcName << "\n" << endl;
							error_writer << "Error at line " << count_line << ": Undeclared function " << funcName << "\n" << endl;
							count_error++;

							string logtext = $1->getName() + "(" + $3->getName() + ")";
							log_writer << logtext << endl << endl;
							SymbolInfo *si = new SymbolInfo(logtext, "factor");
							si->properties.datatype = $1->properties.datatype;
							$$ = si;
						}
				}
	| LPAREN expression RPAREN {
						log_writer << "Line " << count_line << ": factor : LPAREN expression RPAREN\n"<< endl;
						string logtext = "(" + $2->getName() + ")";
						log_writer << logtext << endl << endl;
						SymbolInfo *si = new SymbolInfo(logtext, "factor");
						si->properties.datatype = $2->properties.datatype;
						$$ = si;
					}
	| CONST_INT {
						log_writer << "Line " << count_line << ": factor : CONST_INT\n" << endl;
						$1->properties.datatype = "int";
						log_writer << $1->getName() << endl << endl;

						SymbolInfo *si = new SymbolInfo($1->getName(), $1->getType());
						si->properties.datatype = "int";

						$1->properties.list.push_back(si);
						$$ = $1;
			}
	| CONST_FLOAT {
						log_writer << "Line " << count_line << ": factor : CONST_FLOAT\n" << endl;
						$1->properties.datatype = "float";
						log_writer << $1->getName() << endl << endl;	

						SymbolInfo *si = new SymbolInfo($1->getName(), $1->getType());
						si->properties.datatype = "float";

						$1->properties.list.push_back(si);
						$$ = $1;
				}
	| variable INCOP {
						log_writer << "Line " << count_line << ": factor : variable INCOP\n" << endl;
						
						string logtext = $1->getName() + "++";
						log_writer << logtext << endl << endl;

						SymbolInfo *si = new SymbolInfo(logtext, $1->getType());
						si->properties.datatype = $1->properties.datatype;

						$$ = si;
				}
	| variable DECOP {
						log_writer << "Line " << count_line << ": factor : variable DECOP\n" << endl;
						
						string logtext = $1->getName() + "--";
						log_writer << logtext << endl << endl;

						SymbolInfo *si = new SymbolInfo(logtext, $1->getType());
						si->properties.datatype = $1->properties.datatype;

						$$ = si;
				}
	;
	
argument_list: arguments {
						log_writer << "Line " << count_line << ": argument_list : arguments\n" << endl;
						log_writer << $1->getName() << endl << endl;
						SymbolInfo *si = new SymbolInfo($1->getName(), "argument_list");
						si->properties = $1->properties;
						$$ = si;
					}
			  |	{
				  /*this has to be implemented*/
				  SymbolInfo *si = new SymbolInfo("", "argument_list");
				  $$ = si;
				}
			  ;
	
arguments: arguments COMMA logic_expression {
						log_writer << "Line " << count_line << ": arguments : arguments COMMA logic_expression\n"<< endl;
						string logtext = $1->getName() + "," + $3->getName();
						log_writer << logtext << endl << endl;
						SymbolInfo *si = new SymbolInfo(logtext, "arguments");
						si->properties = $1->properties;
						$$ = si;

						si = new SymbolInfo($3->getName(), $3->getType());
						si->properties.datatype = $3->properties.datatype;
						$$->properties.list.push_back(si);
					}
	      | logic_expression {
			  			log_writer << "Line " << count_line << ": arguments : logic_expression\n" << endl;
						log_writer << $1->getName() << endl << endl;
						SymbolInfo *si = new SymbolInfo($1->getName(), "arguments");
						si->properties.datatype = $1->properties.datatype;
						$$ = si;
						$$->properties.list.push_back(si);
		  			}
	      ;

%%

int main(int argc, char **argv)
{
    if(argc!=2){
		printf("Please provide input file name and try again\n");
		return 0;
	}
	
	FILE *fin=fopen(argv[1],"r");
	if(fin==NULL){
		printf("Cannot open specified file\n");
		return 0;
	}
	

	log_writer.open("log.txt", ios::out);
    error_writer.open("error.txt", ios::out);

	yyin = fin;
	yyparse();
	fclose(yyin);
	return 0;
}
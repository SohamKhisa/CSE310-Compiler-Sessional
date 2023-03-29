%option noyywrap

%x STRING_STATE1
%x STRING_STATE2

%x MULTI_COMMENT
%x COMMENT_STATE1
%x COMMENT_STATE2

%{
#include <cstdlib>
#include <cstring>
#include <cmath>
#include <fstream>
#include "1705120_SymbolTable.h"
#include "y.tab.h"

using namespace std;

extern YYSTYPE yylval;

int count_line = 1;
int count_error = 0;
int str_line = 1;

ofstream log_writer;
ofstream error_writer;
string token, lexeme;
extern bool mainfinish;

string str = "";
string strC = "";

%}

DIGIT   [0-9]
DIGITS  {DIGIT}+
INT_NUMBER1   {DIGITS}(E[+]?{DIGITS})?
INT_NUMBER2   {DIGITS}(e[+]?{DIGITS})?
INT_NUM       ({INT_NUMBER1}|{INT_NUMBER2})
DECIMAL_ERROR ((\.{DIGITS})({DIGITS}|\.)+|({DIGITS}\.)({DIGITS}|\.)+)
ILL_NUMBER    (({DIGITS}|\.|(E[+-]?))+|({DIGITS}\.))
FLOAT_NUMBER1 {DIGITS}?(\.{DIGITS})(E[+-]?{DIGITS})?
FLOAT_NUMBER2 {DIGITS}?(\.{DIGITS})(e[+-]?{DIGITS})?
FLOAT_NUMBER3 {DIGITS}(E[-]{DIGITS})?
FLOAT_NUMBER4 {DIGITS}(e[-]{DIGITS})?
FLOAT_NUM     ({FLOAT_NUMBER1}|{FLOAT_NUMBER2}|{FLOAT_NUMBER3}|{FLOAT_NUMBER4})
RELOP         ((\<\=)|\<|(\>\=)|\>|(\=\=)|(\!\=))
STRING_ESC      (\\\\|\\\"|\\\'|\\n|\\t|\\a|\\b|\\e|\\f|\\v|\\0)
INVALID_NUM_ID  [0-9]+[a-zA-Z]+
IDENTIFIER      [a-zA-Z_][a-zA-Z0-9_]*

%%

"if"    { return IF; }

"for"    { return FOR; }

"do"    { return DO; }

"int"   { return INT; }

"float" { return FLOAT; }

"void"    { return VOID; }

"switch"    { return SWITCH; }

"default"    { return DEFAULT; }

"else"    { return ELSE; }

"while"    { return WHILE; }

"break"    { return BREAK; }

"char"    { return CHAR; }

"double"    { return DOUBLE; }

"return"    { return RETURN; }

"case"    { return CASE; }

"continue" { return CONTINUE; }

"printf" { return PRINTLN; }


{INT_NUM} {
                SymbolInfo *si = new SymbolInfo(yytext, "CONST_INT");
                si->properties.datatype = "int";
                yylval.info = si;
                return CONST_INT;
        }       


{FLOAT_NUM} {
                SymbolInfo *si = new SymbolInfo(yytext, "CONST_FLOAT");
                si->properties.datatype = "float";
                yylval.info = si;
                return CONST_FLOAT;
        }



\'\\n\' {
                // '\n'
                SymbolInfo *si = new SymbolInfo(yytext, "CONST_CHAR");
                yylval.info = si;
                return CONST_CHAR;
        }


\'\\t\' {
                // '\t'
                SymbolInfo *si = new SymbolInfo(yytext, "CONST_CHAR");
                yylval.info = si;
                return CONST_CHAR;
        }


\'\\\\\'  {
                // '\\'
                SymbolInfo *si = new SymbolInfo(yytext, "CONST_CHAR");
                yylval.info = si;
                return CONST_CHAR;
        }


\'\\\'  {
                /* Unterminated character Error has to be handled later */

                //count_error++;
                log_writer << "Error at line no " << count_line << ": Unterminated character " << yytext << endl;
                error_writer << "Error at line no " << count_line << ": Unterminated character " << yytext << endl;
        }


\'\\\'\'  {
                // '\''

                SymbolInfo *si = new SymbolInfo(yytext, "CONST_CHAR");
                yylval.info = si;
                return CONST_CHAR;
        }


\'\\\"\' {      
                // '\"'
                string type = "CONST_CHAR";
                SymbolInfo *si = new SymbolInfo(yytext, "CONST_CHAR");
                yylval.info = si;
                return CONST_CHAR;
        }


\'\\a\'  {
                // '\a'
                SymbolInfo *si = new SymbolInfo(yytext, "CONST_CHAR");
                yylval.info = si;
                return CONST_CHAR;
        }


\'\\f\'  {
                // '\f'
                SymbolInfo *si = new SymbolInfo(yytext, "CONST_CHAR");
                yylval.info = si;
                return CONST_CHAR;
        }


\'\\r\'  {
                // '\r'
                SymbolInfo *si = new SymbolInfo(yytext, "CONST_CHAR");
                yylval.info = si;
                return CONST_CHAR;
        }


\'\\b\'  {
                // '\b'
                SymbolInfo *si = new SymbolInfo(yytext, "CONST_CHAR");
                yylval.info = si;
                return CONST_CHAR;
        }


\'\\v\'  {
                // '\v'
                SymbolInfo *si = new SymbolInfo(yytext, "CONST_CHAR");
                yylval.info = si;
                return CONST_CHAR;
        }


\'\\e\' {
                // '\e'
                SymbolInfo *si = new SymbolInfo(yytext, "CONST_CHAR");
                yylval.info = si;
                return CONST_CHAR;
        }


\'\\0\'  {
                //  '\0'
                SymbolInfo *si = new SymbolInfo(yytext, "CONST_CHAR");
                yylval.info = si;
                return CONST_CHAR;

        }


\'.\'  {
                //code for all characters except for escape

                string type = "CONST_CHAR";
                lexeme = yytext;
                bool v = false;

                /* Not sure if the lexeme should appear in the 1705120.y file or not */

                for (int i=0; i<lexeme.length(); i++) {
                        if(lexeme[i] == '\'') {
                                lexeme.erase(lexeme.begin()+i);
                                break;
                        }
                }

                for (int i=lexeme.length()-1; i>=0; i--) {
                        if(lexeme[i] == '\'') {
                                lexeme.erase(lexeme.begin()+i);
                                break;
                        }
                }
                
                SymbolInfo *si = new SymbolInfo(yytext, "CONST_CHAR");
                yylval.info = si;
                return CONST_CHAR;
        }  

\'(.)(.)+\'        {
                /*Multi character Error has to be handled later*/

                //count_error++;
                log_writer << "Error at line no " << count_line << ": Multi character constant error " << yytext << endl;
                error_writer << "Error at line no " << count_line << ": Multi character constant error " << yytext << endl;
        }

\'\'    {       
                /* Empty character Error has to be handled later */
                //count_error++;
                log_writer << "Error at line no " << count_line << ": Empty character constant error ''" << endl;
                error_writer << "Error at line no " << count_line << ": Empty character constant error ''" << endl;
        }

\'[^\n\r\']*[\n\r]   {
                /* Unterminated character Error has to be handled later */
                //count_error++;
                log_writer << "Error at line no " << count_line << ": Unterminated character " << yytext << endl;
                error_writer << "Error at line no " << count_line << ": Unterminated character " << yytext << endl;
        }


[\+\-]    {
                // + -
                SymbolInfo *si = new SymbolInfo(yytext, "ADDOP");
                yylval.info = si;
                return ADDOP;
        }


[\*\/\%]   {
                // * / %
                SymbolInfo *si = new SymbolInfo(yytext, "MULOP");
                yylval.info = si;
                return MULOP;
        }


(\+\+)   {
                // ++
                SymbolInfo *si = new SymbolInfo(yytext, "INCOP");
                yylval.info = si;
                return INCOP;        
        }

(\-\-)  {
                // ++
                SymbolInfo *si = new SymbolInfo(yytext, "DECOP");
                yylval.info = si;
                return DECOP;
        }

{RELOP} {
                // <= < > >= == !=
                SymbolInfo *si = new SymbolInfo(yytext, "RELOP");
                yylval.info = si;
                return RELOP; 
        }


(\=)    {
                // = (assign)
                
                SymbolInfo *si = new SymbolInfo(yytext, "ASSIGNOP");
                yylval.info = si;
                return ASSIGNOP;
        }


((\&\&)|(\|\|)) {       //  && ||

                SymbolInfo *si = new SymbolInfo(yytext, "LOGICOP");
                yylval.info = si;
                return LOGICOP;
        }


(\!)    {
                //  !

                SymbolInfo *si = new SymbolInfo(yytext, "NOT");
                yylval.info = si;
                return NOT;
        }


(\()    {       
                return LPAREN;        
        }


(\))    {
                return RPAREN;
        }


(\{)    {
                SymbolInfo *si = new SymbolInfo(yytext, "LCURL");
                yylval.info = si;
                return LCURL;
        }


(\})    {       
                SymbolInfo *si = new SymbolInfo(yytext, "RCURL");
                yylval.info = si;
                return RCURL;
        }


(\[)	{
                SymbolInfo *si = new SymbolInfo(yytext, "LTHIRD");
                yylval.info = si;
                return LTHIRD;
	}


(\])    {
                SymbolInfo *si = new SymbolInfo(yytext, "RTHIRD");
                yylval.info = si;
                return RTHIRD;
        }


(\,)	{
                SymbolInfo *si = new SymbolInfo(yytext, "COMMA");
                yylval.info = si;
                return COMMA;
	}


(\;)	{
                SymbolInfo *si = new SymbolInfo(yytext, "SEMICOLON");
                yylval.info = si;
                return SEMICOLON;
	}

{IDENTIFIER}	{
                        // ID
                        SymbolInfo *si = new SymbolInfo(yytext, "ID");
                        yylval.info = si;
                        return ID;
		}

[^ {IDENTIFIER}\"\n\r\t\a\b\v\f\e] {
                        /* Unrecognized character error handling */

                        //count_error++;
                        log_writer << "Error at line " << count_line << ": Unrecognized character " << yytext << endl;
                        error_writer << "Error at line " << count_line << ": Unrecognized character " << yytext << endl;
                }


(\")    { 
                /* Start of a String */
                str = "\"";
                strC = "\"";
                str_line = count_line;
                BEGIN STRING_STATE1;
        }









<STRING_STATE1>\\n {
                        str += "\\n";
                        strC += "\n";
                }

<STRING_STATE1>\\t {
                        str += "\\t";
                        strC += "\t";
                }

<STRING_STATE1>\\a {
                        str += "\\a";
                        strC += "\a";
                }

<STRING_STATE1>\\b {
                        str += "\\b";
                        strC += "\b";
                }
                
<STRING_STATE1>\\f {
                        str += "\\f";
                        strC += "\f";
                }

<STRING_STATE1>\\r {
                        str += "\\r";
                        strC += "\r";
                }

<STRING_STATE1>\\v {
                        str += "\\v";
                        strC += "\v";
                }

<STRING_STATE1>\\0 {
                        str += "\\0";
                        strC += "\0";
                }

<STRING_STATE1>\\\\ {
                        str += "\\\\";
                        strC += "\\";
                }

<STRING_STATE1>\\\" {
                        str += "\\\"";
                        strC += "\"";
                }

<STRING_STATE1>\\\' {
                        str += "\\\'";
                        strC += "\'";
                }


<STRING_STATE2>\\n {
                        str += "\\n";
                        strC += "\n";
                }

<STRING_STATE2>\\t {
                        str += "\\t";
                        strC += "\t";
                }

<STRING_STATE2>\\a {
                        str += "\\a";
                        strC += "\a";
                }

<STRING_STATE2>\\b {
                        str += "\\b";
                        strC += "\b";
                }
                
<STRING_STATE2>\\f {
                        str += "\\f";
                        strC += "\f";
                }

<STRING_STATE2>\\r {
                        str += "\\r";
                        strC += "\r";
                }

<STRING_STATE2>\\v {
                        str += "\\v";
                        strC += "\v";
                }

<STRING_STATE2>\\0 {
                        str += "\\0";
                        strC += "\0";
                }

<STRING_STATE2>\\\\ {
                        str += "\\\\";
                        strC += "\\";
                }

<STRING_STATE2>\\\" {
                        str += "\\\"";
                        strC += "\"";
                }

<STRING_STATE2>\\\' {
                        str += "\\\'";
                        strC += "\'";
                }










<STRING_STATE1>[^\n\"] {      
                        // Accepting all
                        strC += yytext;
                        str += yytext;
                 }

<STRING_STATE2>[^\n\"] {
                        // Accepting all
                        strC += yytext;
                        str += yytext;
                }









<STRING_STATE1>\\[\n\r] {
                        str += yytext;               //str += "\\";
                        BEGIN STRING_STATE2;
                }

<STRING_STATE2>\\[\n\r] {
                        str += yytext;               //str += "\\";
                        BEGIN STRING_STATE1;
                }






<STRING_STATE1>\" {
                        str += "\"";
                        strC += "\"";

                        //log_writer << "\nLine no " << str_line << ": Token <STRING> Lexeme " << str << " found --> " << "<STRING, " << strC << ">" <<endl;
                        if(strC[0]!='\"')
                                strC.insert(0, "\"");
                        //token_writer << "<STRING, " << strC << "> "; 
                        BEGIN INITIAL;
                }

<STRING_STATE2>\" {
                        str += "\"";
                        strC += "\"";

                        //log_writer << "\nLine no " << str_line << ": Token <STRING> Lexeme " << str << " found --> " << "<STRING, " << strC << ">" <<endl;
                        if(strC[0]!='\"')
                                strC.insert(0, "\"");
                        //token_writer << "<STRING, " << strC << "> ";
                        BEGIN INITIAL;
                }





<STRING_STATE1>\n {     
                        int len = str.length();
                        if(str[len-2] != '\\') {
                                log_writer << "Error at line " << str_line << ": Unterminated String " << str << endl;
                                error_writer << "Error at line " << str_line << ": Unterminated String " << str << endl;
                                //count_error++;
                                //count_line += str_line;
                                BEGIN INITIAL;
                        }
                        count_line++;
                        str += yytext;
                 }

<STRING_STATE2>\n {
                        int len = str.length();
                        if(str[len-2] != '\\') {
                                log_writer << "Error at line " << str_line << ": Unterminated String " << str << endl;
                                error_writer << "Error at line " << str_line << ": Unterminated String " << str << endl;
                                //count_error++;
                                //count_line += str_line;
                                BEGIN INITIAL;
                        }
                        count_line++;
                        str += yytext;
                }


<STRING_STATE1><<EOF>>  {
                        log_writer << "Error at line " << str_line << ": Unterminated String " << str << endl;
                        error_writer << "Error at line " << str_line << ": Unterminated String " << str << endl;
                        //count_error++;
                        BEGIN INITIAL;
                }

<STRING_STATE2><<EOF>>  {
                        log_writer << "Error at line " << str_line << ": Unterminated String " << str << endl;
                        error_writer << "Error at line " << str_line << ": Unterminated String " << str << endl;
                        //count_error++;
                        BEGIN INITIAL;
                }






(\/\*)  {
                // Multiline comment
                str_line = count_line;
                str = "/*";
                strC = "/*";
                BEGIN MULTI_COMMENT;
        }

<MULTI_COMMENT>(\*\/) {
                //Multiline comment ends
                str += "*/";
                //log_writer << "\nLine no " << str_line << ": Token <COMMENT> Lexeme " << str << " found" << endl;
                BEGIN INITIAL;
        }

<MULTI_COMMENT>\n {
                        count_line++;
                        str += yytext;
                        strC += yytext;  //it initally was commented;
                }
<MULTI_COMMENT>\t {
                        str += yytext;
                }
<MULTI_COMMENT>\r {}

<MULTI_COMMENT>[\n\r]\t {
                        str += yytext;
                }

<MULTI_COMMENT>. {
                        str += yytext;
                        strC += yytext;
                }
<MULTI_COMMENT><<EOF>> {
                        //count_error++;
                        log_writer << "Error at line " << str_line << ": Unterminated Comment " << strC;
                        error_writer << "Error at line " << str_line << ": Unterminated Comment " << strC;
                        BEGIN INITIAL;       
                }

\/\/      {
                str_line = count_line;
                str = "//";
                BEGIN COMMENT_STATE1;
        }

<COMMENT_STATE1>\\[\n\r] {
                str += yytext;
                BEGIN COMMENT_STATE2;
        }

<COMMENT_STATE1>. { str += yytext; }

<COMMENT_STATE1>\n {
                int len = str.length();
                if(str[len-2] != '\\') {
                        if(str[len-1] == '\r')
                                str.erase(len-1, len-1);
                        //log_writer << "\nLine no " << str_line << ": Token <COMMENT> Lexeme " << str << " found" << endl;
                        BEGIN INITIAL;
                }
                count_line++;
                str += yytext;
        }

<COMMENT_STATE1><<EOF>> { BEGIN INITIAL; }

<COMMENT_STATE2>\\[\n\r] {
                str += yytext;
                BEGIN COMMENT_STATE1;
        }

<COMMENT_STATE2>. { str += yytext; }

<COMMENT_STATE2>\n {
                int len = str.length();
                if(str[len-2] != '\\') {
                        if(str[len-1]=='\r')
                                str.erase(len-1, len-1);
                        //log_writer << "\nLine no " << str_line << ": Token <COMMENT> Lexeme " << str << " found" << endl;
                        BEGIN INITIAL;
                }
                count_line++;
                str += yytext;
        }

<COMMENT_STATE2><<EOF>> { BEGIN INITIAL;}


{INVALID_NUM_ID} {
                        /* Invalid prefix on ID Error has to be handled later */

                        //count_error++;
                        log_writer << "Error at line " << count_line << ": Invalid prefix on ID or invalid suffix on Number " << yytext << endl;
                        error_writer << "Error at line " << count_line << ": Invalid prefix on ID or invalid suffix on Number " << yytext << endl;
                }

{DECIMAL_ERROR} {
                /* too many decimal points Error has to be handled later */

                //count_error++;
                log_writer << "Error at line " << count_line << ": Too many decimal points " << yytext << endl;
                error_writer << "Error at line " << count_line << ": Too many decimal points " << yytext << endl;
        }

{ILL_NUMBER} {
                /* Ill formed number Error has to be handled later */

                //count_error++;
                log_writer << "Error at line " << count_line << ": Ill formed number " << yytext << endl;
                error_writer << "Error at line " << count_line << ": Ill formed number " << yytext << endl;
        }


[ \t\v\r\a\b\f\0]+   {}


(\n)    { if(mainfinish==false) count_line++; }


%%

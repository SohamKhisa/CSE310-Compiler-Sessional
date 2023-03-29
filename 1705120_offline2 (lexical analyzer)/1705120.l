%option noyywrap

%x STRING_STATE1
%x STRING_STATE2

%x MULTI_COMMENT
%x COMMENT_STATE1
%x COMMENT_STATE2

%{

#include <iostream>
#include <bits/stdc++.h>
#include "1705120_SymbolTable.cpp"

using namespace std;

int count_line = 1;
int count_error = 0;
int str_line = 1;
ofstream log_writer;
ofstream token_writer;
string token, lexeme;
string str = "";
string strC = "";

SymbolTable sym(7);

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

"if"    {
            token = "<IF>";
            lexeme = "if";
            token_writer << token << " ";
            log_writer << "\nLine no " << count_line << ": Token " << token << " Lexeme " << lexeme << " found" << endl;
        }


"for"    {
            token = "<FOR>";
            lexeme = "for";
            token_writer << token << " ";
            log_writer << "\nLine no " << count_line << ": Token " << token << " Lexeme " << lexeme << " found" << endl;
        }


"do"    {
            token = "<DO>";
            lexeme = "do";
            token_writer << token << " ";
            log_writer << "\nLine no " << count_line << ": Token " << token << " Lexeme " << lexeme << " found" << endl;
        }


"int"   {
            token = "<INT>";
            lexeme = "int";
            token_writer << token << " ";
            log_writer << "\nLine no " << count_line << ": Token " << token << " Lexeme " << lexeme << " found" << endl;
        }


"float" {
            token = "<FLOAT>";
            lexeme = "float";
            token_writer << token << " ";
            log_writer << "\nLine no " << count_line << ": Token " << token << " Lexeme " << lexeme << " found" << endl;
        }


"void"    {
            token = "<VOID>";
            lexeme = "void";
            token_writer << token << " ";
            log_writer << "\nLine no " << count_line << ": Token " << token << " Lexeme " << lexeme << " found" << endl;
        }


"switch"    {
            token = "<SWITCH>";
            lexeme = "switch";
            token_writer << token << " ";
            log_writer << "\nLine no " << count_line << ": Token " << token << " Lexeme " << lexeme << " found" << endl;
        }


"default"    {
            token = "<DEFAULT>";
            lexeme = "default";
            token_writer << token << " ";
            log_writer << "\nLine no " << count_line << ": Token " << token << " Lexeme " << lexeme << " found" << endl;
        }


"else"    {
            token = "<ELSE>";
            lexeme = "else";
            token_writer << token << " ";
            log_writer << "\nLine no " << count_line << ": Token " << token << " Lexeme " << lexeme << " found" << endl;
        }


"while"    {
            token = "<WHILE>";
            lexeme = "while";
            token_writer << token << " ";
            log_writer << "\nLine no " << count_line << ": Token " << token << " Lexeme " << lexeme << " found" << endl;
        }


"break"    {
            token = "<BREAK>";
            lexeme = "break";
            token_writer << token << " ";
            log_writer << "Line no " << count_line << ": Token " << token << " Lexeme " << lexeme << " found\n" << endl;
        }


"char"    {
            token = "<CHAR>";
            lexeme = "char";
            token_writer << token << " ";
            log_writer << "\nLine no " << count_line << ": Token " << token << " Lexeme " << lexeme << " found" << endl;
        }


"double"    {
            token = "<DOUBLE>";
            lexeme = "double";
            token_writer << token << " ";
            log_writer << "\nLine no " << count_line << ": Token " << token << " Lexeme " << lexeme << " found" << endl;
        }


"return"    {
            token = "<RETURN>";
            lexeme = "return";
            token_writer << token << " ";
            log_writer << "\nLine no " << count_line << ": Token " << token << " Lexeme " << lexeme << " found" << endl;
        }


"case"    {
            token = "<CASE>";
            lexeme = "case";
            token_writer << token << " ";
            log_writer << "\nLine no " << count_line << ": Token " << token << " Lexeme " << lexeme << " found" << endl;
        }


"continue" {
            token = "<CONTINUE>";
            lexeme = "continue";
            token_writer << token << " ";
            log_writer << "\nLine no " << count_line << ": Token " << token << " Lexeme " << lexeme << " found" << endl;
        }


{INT_NUM}  {
            string symbol = yytext;
            string type = "CONST_INT";
            bool v = false;

            token = "<" + type + ", " + symbol + ">";
            token_writer << token << " ";
            
            token = "<" + type + ">";
            lexeme = yytext;
            log_writer << "\nLine no " << count_line << ": Token " << token << " Lexeme " << lexeme << " found" << endl;

            v = sym.inSert(symbol, type, log_writer);
            if(v)  sym.print_alltable(log_writer);
        }       


{FLOAT_NUM} {
            string symbol = yytext;
            string type = "CONST_FLOAT";
            bool v = false;

            token = "<" + type + ", " + symbol + ">";
            token_writer << token << " ";
            
            token = "<" + type + ">";
            lexeme = yytext;
            log_writer << "\nLine no " << count_line << ": Token " << token << " Lexeme " << lexeme << " found" << endl;

            v = sym.inSert(symbol, type, log_writer);
            if(v)   sym.print_alltable(log_writer);
        }



\'\\n\' {
                // '\n'

                string type = "CHAR_CONST";
                char temp = '\n';                     //it needs to be converted to string;
                string symbol = string(1, temp);
                lexeme = yytext;
                bool v = false;
                
                token = "<" + type + ", " + symbol + ">";
                token_writer << token << " ";
                type = "CONST_CHAR";

                token = "<" + type + ">";
                string s = "<" + type + ", " + symbol + ">";
                log_writer << "\nLine no " << count_line << ": Token " << token << " Lexeme " << lexeme << " found --> " << s << endl;

                v = sym.inSert(lexeme, type, log_writer);
                if(v)  sym.print_alltable(log_writer);

        }


\'\\t\' {
                // '\t'

                string type = "CONST_CHAR";
                char temp = '\t';                     //it needs to be converted to string;
                string symbol = string(1, temp);
                lexeme = yytext;
                bool v = false;
                
                token = "<" + type + ", " + symbol + ">";
                token_writer << token << " ";

                token = "<" + type + ">";
                string s = "<" + type + ", " + symbol + ">";
                log_writer << "\nLine no " << count_line << ": Token " << token << " Lexeme " << lexeme << " found --> " << s << endl;

                v = sym.inSert(lexeme, type, log_writer);
                if(v)  sym.print_alltable(log_writer);
        }


\'\\\\\'  {
                // '\\'

                string type = "CONST_CHAR";
                char temp = '\\';                     //it needs to be converted to string;
                string symbol = string(1, temp);
                lexeme = yytext;
                bool v = false;
                
                token = "<" + type + ", " + symbol + ">";
                token_writer << token << " ";

                token = "<" + type + ">";
                string s = "<" + type + ", " + symbol + ">";
                log_writer << "\nLine no " << count_line << ": Token " << token << " Lexeme " << lexeme << " found --> " << s << endl;

                v = sym.inSert(lexeme, type, log_writer);
                if(v)  sym.print_alltable(log_writer);
        }


\'\\\'  {
                count_error++;
                log_writer << "\nError at line no " << count_line << ": Unterminated character " << yytext << endl;
        }


\'\\\'\'  {
                // '\''

                string type = "CONST_CHAR";
                char temp = '\'';                     //it needs to be converted to string;
                string symbol = string(1, temp);
                lexeme = yytext;
                bool v = false;
                
                token = "<" + type + ", " + symbol + ">";
                token_writer << token << " ";

                token = "<" + type + ">";
                string s = "<" + type + ", " + symbol + ">";
                log_writer << "\nLine no " << count_line << ": Token " << token << " Lexeme " << lexeme << " found --> " << s << endl;

                v = sym.inSert(lexeme, type, log_writer);
                if(v)  sym.print_alltable(log_writer);
        }


\'\\\"\' {      // '\"'
                string type = "CONST_CHAR";
                char temp = '\"';                     //it needs to be converted to string;
                string symbol = string(1, temp);
                lexeme = yytext;
                bool v = false;
                
                token = "<" + type + ", " + symbol + ">";
                token_writer << token << " ";

                token = "<" + type + ">";
                string s = "<" + type + ", " + symbol + ">";
                log_writer << "\nLine no " << count_line << ": Token " << token << " Lexeme " << lexeme << " found --> " << s << endl;

                v = sym.inSert(lexeme, type, log_writer);
                if(v)  sym.print_alltable(log_writer);
        }


\'\\a\'  {
                // '\a'
                string type = "CONST_CHAR";
                char temp = '\a';                     //it needs to be converted to string;
                string symbol = string(1, temp);
                lexeme = yytext;
                bool v = false;
                
                token = "<" + type + ", " + symbol + ">";
                token_writer << token << " ";

                token = "<" + type + ">";
                string s = "<" + type + ", " + symbol + ">";
                log_writer << "\nLine no " << count_line << ": Token " << token << " Lexeme " << lexeme << " found --> " << s << endl;

                v = sym.inSert(lexeme, type, log_writer);
                if(v)  sym.print_alltable(log_writer);
        }


\'\\f\'  {
                // '\f'
                string type = "CONST_CHAR";
                char temp = '\f';                     //it needs to be converted to string;
                string symbol = string(1, temp);
                lexeme = yytext;
                bool v = false;
                
                token = "<" + type + ", " + symbol + ">";
                token_writer << token << " ";

                token = "<" + type + ">";
                string s = "<" + type + ", " + symbol + ">";
                log_writer << "\nLine no " << count_line << ": Token " << token << " Lexeme " << lexeme << " found --> " << s << endl;

                v = sym.inSert(lexeme, type, log_writer);
                if(v)  sym.print_alltable(log_writer);
        }


\'\\r\'  {
                // '\r'
                string type = "CONST_CHAR";
                char temp = '\r';                     //it needs to be converted to string;
                string symbol = string(1, temp);
                lexeme = yytext;
                bool v = false;
                
                token = "<" + type + ", " + symbol + ">";
                token_writer << token << " ";

                token = "<" + type + ">";
                string s = "<" + type + ", " + symbol + ">";
                log_writer << "\nLine no " << count_line << ": Token " << token << " Lexeme " << lexeme << " found --> " << s << endl;

                v = sym.inSert(lexeme, type, log_writer);
                if(v)  sym.print_alltable(log_writer);
        }


\'\\b\'  {
                // '\b'
                string type = "CONST_CHAR";
                char temp = '\b';                     //it needs to be converted to string;
                string symbol = string(1, temp);
                lexeme = yytext;
                bool v = false;
                
                token = "<" + type + ", " + symbol + ">";
                token_writer << token << " ";

                token = "<" + type + ">";
                string s = "<" + type + ", " + symbol + ">";
                log_writer << "\nLine no " << count_line << ": Token " << token << " Lexeme " << lexeme << " found --> " << s << endl;

                v = sym.inSert(lexeme, type, log_writer);
                if(v)  sym.print_alltable(log_writer);
        }


\'\\v\'  {
                // '\v'
                string type = "CONST_CHAR";
                char temp = '\v';                     //it needs to be converted to string;
                string symbol = string(1, temp);
                lexeme = yytext;
                bool v = false;
                
                token = "<" + type + ", " + symbol + ">";
                token_writer << token << " ";

                token = "<" + type + ">";
                string s = "<" + type + ", " + symbol + ">";
                log_writer << "\nLine no " << count_line << ": Token " << token << " Lexeme " << lexeme << " found --> " << s << endl;

                v = sym.inSert(lexeme, type, log_writer);
                if(v)  sym.print_alltable(log_writer);
        }


\'\\e\' {
                // '\e'
                string type = "CONST_CHAR";
                char temp = '\e';                     //it needs to be converted to string;
                string symbol = string(1, temp);
                lexeme = yytext;
                bool v = false;
                
                token = "<" + type + ", " + symbol + ">";
                token_writer << token << " ";

                token = "<" + type + ">";
                string s = "<" + type + ", " + symbol + ">";
                log_writer << "\nLine no " << count_line << ": Token " << token << " Lexeme " << lexeme << " found --> " << s << endl;

                v = sym.inSert(lexeme, type, log_writer);
                if(v)  sym.print_alltable(log_writer);
        }


\'\\0\'  {
                //  '\0'
                string type = "CONST_CHAR";
                char temp = '\0';                     //it needs to be converted to string;
                string symbol = string(1, temp);
                lexeme = yytext;
                bool v = false;
                
                token = "<" + type + ", " + symbol + ">";
                token_writer << token << " ";

                token = "<" + type + ">";
                string s = "<" + type + ", " + symbol + ">";
                log_writer << "\nLine no " << count_line << ": Token " << token << " Lexeme " << lexeme << " found --> " << s << endl;

                v = sym.inSert(lexeme, type, log_writer);
                if(v)  sym.print_alltable(log_writer);

        }


\'.\'  {
                //code for all characters except for escape

                string type = "CONST_CHAR";
                lexeme = yytext;
                bool v = false;

                for (int i=0; i<lexeme.length(); i++) {
                        if(lexeme[i] == '\'') {
                                lexeme.erase(lexeme.begin()+i);
                                break;
                        }
                }

                for(int i=lexeme.length()-1; i>=0; i--) {
                        if(lexeme[i] == '\'') {
                                lexeme.erase(lexeme.begin()+i);
                                break;
                        }
                }

                token = "<" + type + ", " + lexeme + ">";
                token_writer << token << " ";
                
                token = "<" + type + ">";
                string s = "<" + type + ", " + lexeme + ">";
                log_writer << "\nLine no " << count_line << ": Token " << token << " Lexeme " << yytext << " found --> " << s << endl;

                v = sym.inSert(yytext, type, log_writer);
                if(v)   sym.print_alltable(log_writer);
        }  

\'(.)(.)+\'        {
                count_error++;
                log_writer << "\nError at line no " << count_line << ": Multi character constant error " << yytext << endl;
        }

\'\'    {       
                count_error++;
                log_writer << "\nError at line no " << count_line << ": Empty character constant error ''" << endl;
        }

\'[^\n\r\']*[\n\r]   {
                count_error++;
                log_writer << "\nError at line no " << count_line << ": Unterminated character " << yytext << endl;
        }


[\+\-]    {
                // + -

                lexeme = yytext;
                token = "<ADDOP, " + lexeme + ">";
                token_writer << token << " ";
                token = "<ADDOP>";
                log_writer << "\nLine no " << count_line << ": Token " << token << " Lexeme " << lexeme << " found" << endl;

        }


[\*\/\%]   {
                // * / %

                lexeme = yytext;
                token = "<MULOP, " + lexeme + ">";
                token_writer << token << " ";
                token = "<MULOP>";
                log_writer << "\nLine no " << count_line << ": Token " << token << " Lexeme " << lexeme << " found" << endl;
        }


(\+\+|\-\-)   {
                // ++ --
                lexeme = yytext;
                token = "<INCOP, " + lexeme + ">";
                token_writer << token << " ";
                token = "<INCOP>";
                log_writer << "\nLine no " << count_line << ": Token " << token << " Lexeme " << lexeme << " found" << endl;
        
        }

{RELOP} {
                // <= < > >= == !=
                lexeme = yytext;
                token = "<RELOP, " + lexeme + ">";
                token_writer << token << " ";
                token = "<RELOP>";
                log_writer << "\nLine no " << count_line << ": Token " << token << " Lexeme " << lexeme << " found" << endl;
        }


(\=)    {
                // = (assign)
                lexeme = yytext;
                token = "<ASSIGNOP, " + lexeme + ">";
                token_writer << token << " ";
                token = "<ASSIGNOP>";
                log_writer << "\nLine no " << count_line << ": Token " << token << " Lexeme " << lexeme << " found" << endl;
        }


((\&\&)|(\|\|)) {       //  && ||

                lexeme = yytext;
                token = "<LOGICOP, " + lexeme + ">";
                token_writer << token << " ";
                token = "<LOGICOP>";
                log_writer << "\nLine no " << count_line << ": Token " << token << " Lexeme " << lexeme << " found" << endl;

        }


(\!)    {
                //  !

                lexeme = yytext;
                token = "<NOP, " + lexeme + ">";
                token_writer << token << " ";
                token = "<NOP>";
                log_writer << "\nLine no " << count_line << ": Token " << token << " Lexeme " << lexeme << " found" << endl;
        }


(\()    {       
                lexeme = yytext;
                token = "<LPAREN, " + lexeme + ">";
                token_writer << token << " ";
                token = "<LPAREN>";
                log_writer << "\nLine no " << count_line << ": Token " << token << " Lexeme " << lexeme << " found" << endl;
        }


(\))    {
                lexeme = yytext;
                token = "<RPAREN, " + lexeme + ">";
                token_writer << token << " ";
                token = "<RPAREN>";
                log_writer << "\nLine no " << count_line << ": Token " << token << " Lexeme " << lexeme << " found" << endl;
        }


(\{)    {
                lexeme = yytext;
                token = "<LCURL, " + lexeme + ">";
                token_writer << token << " ";
                token = "<LCURL>";
                log_writer << "\nLine no " << count_line << ": Token " << token << " Lexeme " << lexeme << " found" << endl;
                sym.enter_scop();
        }


(\})    {       
                lexeme = yytext;
                token = "<RCURL, " + lexeme + ">";
                token_writer << token << " ";
                token = "<RCURL>";
                log_writer << "\nLine no " << count_line << ": Token " << token << " Lexeme " << lexeme << " found" << endl;
                sym.exit_scop();
        }


(\[)	{
                lexeme = yytext;
                token = "<LTHIRD, " + lexeme + ">";
                token_writer << token << " ";
                token = "<LTHIRD>";
                log_writer << "\nLine no " << count_line << ": Token " << token << " Lexeme " << lexeme << " found" << endl;
	}


(\])	{
                lexeme = yytext;
                token = "<RTHIRD, " + lexeme + ">";
                token_writer << token << " ";
                token = "<RTHIRD>";
                log_writer << "\nLine no " << count_line << ": Token " << token << " Lexeme " << lexeme << " found" << endl;
	}


(\,)	{
                lexeme = yytext;
                token = "<COMMA, " + lexeme + ">";
                token_writer << token << " ";
                token = "<COMMA>";
                log_writer << "\nLine no " << count_line << ": Token " << token << " Lexeme " << lexeme << " found" << endl;
	}


(\;)	{
                lexeme = yytext;
                token = "<SEMICOLON, " + lexeme + ">";
                token_writer << token << " ";
                token = "<SEMICOLON>";
                log_writer << "\nLine no " << count_line << ": Token " << token << " Lexeme " << lexeme << " found" << endl;
	}

{IDENTIFIER}	{
				// ID
                                string symbol = yytext;
                                string type = "ID";
                                bool v = false;

                                token = "<" + type + ", " + symbol + ">";
                                token_writer << token << " ";

                                token = "<" + type + ">";
                                lexeme = yytext;
                                log_writer << "\nLine no " << count_line << ": Token " << token << " Lexeme " << lexeme << " found" << endl;
                                
                                v = sym.inSert(symbol, type, log_writer);
                                if(v)   sym.print_alltable(log_writer);

			}

[^ {IDENTIFIER}\"\n\r\t\a\b\v\f\e] {
                        count_error++;
                        log_writer << "\nError at line no " << count_line << ": Unrecognized character " << yytext << endl;
                }


(\")    { 
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

                        log_writer << "\nLine no " << str_line << ": Token <STRING> Lexeme " << str << " found --> " << "<STRING, " << strC << ">" <<endl;
                        if(strC[0]!='\"')
                                strC.insert(0, "\"");
                        token_writer << "<STRING, " << strC << "> "; 
                        BEGIN INITIAL;
                }

<STRING_STATE2>\" {
                        str += "\"";
                        strC += "\"";

                        log_writer << "\nLine no " << str_line << ": Token <STRING> Lexeme " << str << " found --> " << "<STRING, " << strC << ">" <<endl;
                        if(strC[0]!='\"')
                                strC.insert(0, "\"");
                        token_writer << "<STRING, " << strC << "> ";
                        BEGIN INITIAL;
                }





<STRING_STATE1>\n {     
                        int len = str.length();
                        if(str[len-2] != '\\') {
                                log_writer << "\nError at line no " << str_line << ": Unterminated String " << str << endl;
                                count_error++;
                                //count_line += str_line;
                                BEGIN INITIAL;
                        }
                        count_line++;
                        str += yytext;
                 }

<STRING_STATE2>\n {
                        int len = str.length();
                        if(str[len-2] != '\\') {
                                log_writer << "\nError at line no " << str_line << ": Unterminated String " << str << endl;
                                count_error++;
                                //count_line += str_line;
                                BEGIN INITIAL;
                        }
                        count_line++;
                        str += yytext;
                }


<STRING_STATE1><<EOF>>  {
                        log_writer << "\nError at line no " << str_line << ": Unterminated String " << str << endl;
                        count_error++;
                        BEGIN INITIAL;
                }

<STRING_STATE2><<EOF>>  {
                        log_writer << "\nError at line no " << str_line << ": Unterminated String " << str << endl;
                        count_error++;
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
                log_writer << "\nLine no " << str_line << ": Token <COMMENT> Lexeme " << str << " found" << endl;
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
                        count_error++;
                        log_writer << "\nError at line no " << str_line << ": Unterminated Comment " << strC;
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
                        log_writer << "\nLine no " << str_line << ": Token <COMMENT> Lexeme " << str << " found" << endl;
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
                        log_writer << "\nLine no " << str_line << ": Token <COMMENT> Lexeme " << str << " found" << endl;
                        BEGIN INITIAL;
                }
                count_line++;
                str += yytext;
        }

<COMMENT_STATE2><<EOF>> { BEGIN INITIAL;}


{INVALID_NUM_ID} {
                        count_error++;
                        log_writer << "\nError at line no " << count_line << ": Invalid prefix on ID or invalid suffix on Number " << yytext << endl;
                }

{DECIMAL_ERROR} {
            count_error++;
            log_writer << "\nError at line no " << count_line << ": Too many decimal points " << yytext << endl;
        }

{ILL_NUMBER} {
        
            count_error++;
            log_writer << "\nError at line no " << count_line << ": Ill formed number " << yytext << endl;
        }


[ \t\v\r\a\b\f\0]+   {}


(\n)    { count_line++; }


<<EOF>> {
                sym.print_alltable(log_writer);
                log_writer << "\nTotal lines: " << --count_line << endl;
                log_writer << "Total errors: " << count_error << endl;
                return 0;
        }

     

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
	

	log_writer.open("1705120_log.txt", ios::out);
        token_writer.open("1705120_token.txt", ios::out);

	yyin = fin;
	yylex();
	fclose(yyin);
	return 0;
}
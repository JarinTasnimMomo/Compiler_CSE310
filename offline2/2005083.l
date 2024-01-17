%option noyywrap

%x CState
%x Stringstate
%x MulticommentState

%{
#include<iostream>
#include<fstream>
#include<string>
#include "2005083.cpp"
using namespace std;

int line_count=1;
int error_counter=0;
int warnings=0;
int bucket=10;
int new_line=0;
int new_line1=0;
int new_line2=0;

string char_ans;
string plain_char;

string final_str;
string plain_str;
ofstream logout;

ofstream tokenout;

SymbolTable symTable;

string single_comment;
string multi_comment;
%}

%{
//symTable.Enter_scope(bucket, logout);
void print_to_log(ofstream &out, const char* name, const char* tex)
{
    out<<"Line# "<<line_count<<": Token <"<<name<<"> Lexeme "<<tex<<" found\n";
}

void print_to_token(ofstream &out, const char* nam, const char* t)
{
    //out<<"Line no "<<line_count<<": TOKEN <CONST_CHAR> Lexeme "<<tex<<" found\n";
    //out<<"Line no %d: TOKEN <CONST_CHAR> Lexeme %s found\n",line_count,tex;
    out<<"<"<<nam<<", "<<t<<">\n";
}
 


%}

WHITESPACE [ \t\f\r\v]+ 
LETTER [a-zA-Z_]
ALPHANUMERIC [a-zA-Z_0-9]
DIGIT [0-9]

EXPONENT ([Ee][+-]?{DIGIT}+)
CONST_FLOAT {DIGIT}+{EXPONENT}|{DIGIT}+\.{DIGIT}+?{EXPONENT}?|\.{DIGIT}+{EXPONENT}?

NEWLINE \n


ILLFORMED_EXPONENT [Ee][-+\.0-9]+[-+Ee\.0-9]*
ILLFORMED_NUMBER {DIGIT}+(\.[0-9]*)?{ILLFORMED_EXPONENT}

TOO_MANY_DECIMAL_POINTS (\.)*({DIGIT}+(\.)*)+

%%
{NEWLINE} {line_count++;}
{WHITESPACE} {}
"if"	{
			tokenout<<"<IF, if>\n";
			print_to_log(logout,"IF",yytext);
		}
		
"else"	{
			tokenout<<"<ELSE, else>\n";
			print_to_log(logout,"ELSE",yytext);
		}

"for"	{
			tokenout<<"<FOR, for>\n";
			print_to_log(logout,"FOR",yytext);
		}

"while"	{
			tokenout<<"<WHILE, while>\n";
			print_to_log(logout,"WHILE",yytext);
		}

"do"	{
			tokenout<<"<DO, do>\n";
			print_to_log(logout,"DO",yytext);
		}	

"break"	{
			tokenout<<"<BREAK, break>\n";
			print_to_log(logout,"BREAK",yytext);
		}

"int"	{
			tokenout<<"<INT, int>\n";
			print_to_log(logout,"INT",yytext);
		}

"char"	{
			tokenout<<"<CHAR, char>\n";
			print_to_log(logout,"CHAR",yytext);
		}

"float"	{
			tokenout<<"<FLOAT, float>\n";
			print_to_log(logout,"FLOAT",yytext);
		}

"double"	{
			tokenout<<"<DOUBLE, double>\n";
			print_to_log(logout,"DOUBLE",yytext);
		}

"void"	{
			tokenout<<"<VOID, void>\n";
			print_to_log(logout,"VOID",yytext);
		}

"return"	{
			tokenout<<"<RETURN, return>\n";
			print_to_log(logout,"RETURN",yytext);
		}

"switch"	{
			tokenout<<"<SWITCH, switch>\n";
			print_to_log(logout,"SWITCH",yytext);
		}

"case"	{
			tokenout<<"<CASE, case>\n";
			print_to_log(logout,"CASE",yytext);
		}	

"default"	{
			tokenout<<"<DEFAULT, default>\n";
			print_to_log(logout,"DEFAULT",yytext);
		}

"continue"	{
			tokenout<<"<CONTINUE, continue>\n";
			print_to_log(logout,"CONTINUE",yytext);
		}																	




"(" {
			print_to_token(tokenout,"LPAREN",yytext);
			print_to_log(logout,"LPAREN",yytext);
		}

 ")" {
			print_to_token(tokenout,"RPAREN",yytext);
			print_to_log(logout,"RPAREN",yytext);
		} 

"{" {
			print_to_token(tokenout,"LCURL",yytext);
			print_to_log(logout,"LCURL",yytext);
			symTable.Enter_scope(10, logout);
			cout<<"lcurl\n";
            
		}

"}" {
			print_to_token(tokenout,"RCURL",yytext);
			print_to_log(logout,"RCURL",yytext);
			cout<<"rcurl\n";
            symTable.Exit_scope(logout,8);
		}

"[" {
			print_to_token(tokenout,"LSQUARE",yytext);
			print_to_log(logout,"LSQUARE",yytext);
		}

"]" {
			print_to_token(tokenout,"RSQUARE",yytext);
			print_to_log(logout,"RSQUARE",yytext);
		}

"," {
			print_to_token(tokenout,"COMMA",yytext);
			print_to_log(logout,"COMMA",yytext);
		}

";" {
			print_to_token(tokenout,"SEMICOLON",yytext);
			print_to_log(logout,"SEMICOLON",yytext);
		}

"*"  | 
"\/" |
"%"  {
			print_to_token(tokenout,"MULOP",yytext);
			print_to_log(logout,"MULOP",yytext);
	 }

"++" | 
"--" {
			print_to_token(tokenout,"INCOP",yytext);
			print_to_log(logout,"INCOP",yytext);
			
	 }
"+"		|

"-"		{
			print_to_token(tokenout,"ADDOP",yytext);
			print_to_log(logout,"ADDOP",yytext);
			
		}		

"<"  | 
"<=" |
">"  |
">=" |
"==" |
"!=" {
			print_to_token(tokenout,"RELOP",yytext);
			print_to_log(logout,"RELOP",yytext);
	 }

"=" {
			print_to_token(tokenout,"ASSIGNOP",yytext);
			print_to_log(logout,"ASSIGNOP",yytext);
	}

"&&" |
"||" {
			print_to_token(tokenout,"LOGICOP",yytext);
			print_to_log(logout,"LOGICOP",yytext);
	 }		

"&" |
"|" |
 "^" |
"<<" |
">>" {
			print_to_token(tokenout,"BITOP",yytext);
			print_to_log(logout,"BITOP",yytext);
	 }

"!" {
			print_to_token(tokenout,"NOT",yytext);
			print_to_log(logout,"NOT",yytext);
		}

{LETTER}{ALPHANUMERIC}* {
		print_to_token(tokenout,"ID",yytext);
        print_to_log(logout,"ID",yytext); 
		
		if(symTable.Insert(yytext,"ID",logout))
		{	
			cout<<yytext<<endl;
			symTable.Print_All_Scope_tables(logout);
		}

		}

{DIGIT}+ 	{
				
                print_to_token(tokenout,"CONST_INT",yytext);
                print_to_log(logout,"CONST_INT",yytext);
			}
{CONST_FLOAT} {   
                print_to_token(tokenout,"CONST_FLOAT",yytext);
                print_to_log(logout,"CONST_FLOAT",yytext);    
			
			}	

\'	{
	char_ans.clear();
	plain_char.clear();
	BEGIN CState;
	
}
<CState>\\\\ {
	char_ans += "\\";
	plain_char+="\\\\";

}
<CState>\\\' {
	char_ans += "\'";
	plain_char+="\\\'";

}
<CState>\\\" {
	char_ans += "\"";
	plain_char+="\\\"";

}
<CState>\\a {
	char_ans += "\a";
	plain_char+="\\a";

}
<CState>\\b {
	char_ans += "\b";
	plain_char+="\\b";

}
<CState>\\v {
	char_ans += "\v";
	plain_char+="\\v";

}
<CState>\\r {
	char_ans += "\r";
	plain_char+="\\r";

}
<CState>\\t {
	char_ans += "\t";
	plain_char+="\\t";

}
<CState>\\f {
	char_ans += "\f";
	plain_char+="\\f";

}
<CState>\\n {
	char_ans += "\n";
	plain_char+="\\n";

}
<CState>\\0 {
	char_ans += "\0";
	plain_char+="\\0";

}

<CState><<EOF>> {
	string to_print="'";
	to_print+=plain_char;
	//to_print+="'";
	error_counter++;
	
	logout <<"Error at line# "<<line_count<<": Unterminated Character "<<to_print<<'\n';
	BEGIN INITIAL;

}
<CState>\' {
	string tp="'";
	tp+=plain_char;
	

	if((int)char_ans.size()==0)
	{
		if(plain_char=="\\0")
		{	
			tp+= "'";
			tokenout<<"<CONST_CHAR"<<", "<<char_ans<<">\n";
			logout<<"Line# "<<line_count<<": Token <CONST_CHAR"<<"> Lexeme "<<plain_char<<" found\n";
		}
		else{
			error_counter++;
			tp+= "'";
			logout <<"Error at line# "<<line_count<<": EMPTY_CONST_CHAR "<<tp<<'\n';
		}
	}
	else if((int)char_ans.size()==1)
	{	
		tp+= "'";
		tokenout<<"<CONST_CHAR"<<", "<<char_ans<<">\n";
		logout<<"Line# "<<line_count<<": Token <CONST_CHAR"<<"> Lexeme "<<plain_char<<" found\n";
	}
	else{
		error_counter++;
		tp+= "'";
		logout <<"Error at line# "<<line_count<<": MULTICHAR_CONST_CHAR "<<tp<<'\n';
		BEGIN INITIAL;
	}
	BEGIN INITIAL;
}

<CState>[\r]?\n {
	string p="'";
	p+=plain_char;
	//p+="'";
	
	error_counter++;
	logout <<"Error at line# "<<line_count<<": UNFINISHED_CONST_CHAR "<<p<<'\n';

	line_count++;
	BEGIN INITIAL;
}
<CState>. {
	char_ans+=yytext[0];
	plain_char+=yytext[0];
}




{ILLFORMED_NUMBER} {
	error_counter++;
	logout <<"Error at line# "<<line_count<<": ILLFORMED_NUMBER "<<yytext<<'\n';
}
{TOO_MANY_DECIMAL_POINTS} {
	error_counter++;
	logout <<"Error at line# "<<line_count<<": TOO_MANY_DECIMAL_POINTS "<<yytext<<'\n';

}
{DIGIT}*(\.{DIGIT}+)?(E[+-]?{DIGIT}+)?{LETTER}{ALPHANUMERIC}* {
	error_counter++;
	logout<<"Error at line# "<< line_count <<": INVALID_ID_SUFFIX_NUM_PREFIX "<<yytext<<"\n";
}

\" {
	final_str.clear();
	plain_str.clear();
	new_line=0;
	BEGIN Stringstate;
}
\/\*	{
	multi_comment.clear();
	multi_comment += "/*";

	new_line = 0;

	BEGIN MulticommentState;
	
}
<Stringstate>\\\\ {
	final_str+="\\";
	plain_str+="\\\\";
}

<Stringstate>\\\' {
	final_str+="\'"; 
	plain_str+="\\\'";
}

<Stringstate>\\\" {
	final_str+="\"";
	plain_str+="\\\"";
}

<Stringstate>\\a {
	final_str+="\a";
	plain_str+="\\a";
}

<Stringstate>\\b {
	final_str+="\b";
	plain_str+="\\b";
}
<Stringstate>\\f {
	final_str+="\f";
	plain_str+="\\f";
}
<Stringstate>\\r {
	final_str+="\r";
	plain_str+="\\r";
}
<Stringstate>\\n {
	final_str+="\n";
	plain_str+="\\n";
}
<Stringstate>\\t {
	final_str+="\t";
	plain_str+="\\t";
}
<Stringstate>\\v {
	final_str+="\v";
	plain_str+="\\v";
}
<Stringstate>\\0 {
	final_str+="\0";
	plain_str+="\\0";
}
<Stringstate>\\\r\n {
	new_line++;
	plain_str+="\\\r\n";
}
<Stringstate>\\\n {
	new_line++;
	plain_str+="\\\n";
}
<Stringstate>[\r]?\n {
	new_line++;
	error_counter++;
	string pri="\"";
	pri+=plain_str;
	cout<<plain_str;
	
	logout <<"Error at line# "<<line_count<<": UNFINISHED_STRING "<<pri<<'\n';
	line_count+=new_line;
	new_line=0;
	BEGIN INITIAL;

}
<Stringstate><<EOF>> {
	string to_prin="\"";
	to_prin+=plain_str;
	error_counter++;
	cout<<to_prin;
	logout <<"Error at line# "<<line_count<<": UNFINISHED_STRING "<<to_prin<<'\n';
	BEGIN INITIAL;

}

<Stringstate>\" {
	
	string totoken;
	totoken+=final_str;
	
	
	
	string tolog="\"";
	tolog+=plain_str;
	tolog+="\"";
	
	if(new_line==0)
	{
		tokenout<<"<SINGLE LINE STRING, "<<totoken<<">\n";
		logout<<"Line# "<<line_count<<": Token <SINGLE LINE STRING"<<"> Lexeme "<<tolog<<" found\n";
	}
	else{
		tokenout<<"<MULTI LINE STRING, "<<totoken<<">\n";
		logout<<"Line# "<<line_count<<": Token <MULTI LINE STRING"<<"> Lexeme "<<tolog<<" found\n";
	}


	line_count+=new_line;
	new_line=0;
	totoken.clear();
	BEGIN INITIAL;
}
<Stringstate>. {
	final_str+=yytext[0];
	plain_str+=yytext[0];
}



\/\/.*(\\(\r)?\n.*)* {
  //single line
  //tokenout<<"<SINGLE LINE COMMENT, "<<yytext<<">\n";
  //cout<<yyleng;
  single_comment.clear();
	for(int i=0;i<yyleng;i++)
	{	
		

		if(i!=yyleng-1)
		{
			single_comment+=yytext[i];
		}
		
		if(yytext[i]=='\n')
		{
			new_line1++;
		}
	}


	

  logout<<"Line# "<<line_count<<": Token <SINGLE LINE COMMENT"<<"> Lexeme "<<single_comment<<" found\n";
  line_count+=new_line1;
	new_line1=0;
	cout<<single_comment;

}



<MulticommentState>\*\/ {
	multi_comment+="*/";
	logout<<"Line# "<<line_count<<": Token <MULTI LINE COMMENT"<<"> Lexeme "<<multi_comment<<" found\n";
	line_count+=new_line;
	new_line=0;
	BEGIN INITIAL;

}
<MulticommentState><<EOF>> {
	error_counter++;
	line_count+=new_line;
	//logout<<"Line# "<<line_count<<": Token <MULTI LINE COMMENT"<<"> Lexeme "<<multi_comment<<" found\n";
	logout<<"Error at line# "<< line_count <<": UNFINISHED_COMMENT "<<multi_comment<<"\n";

	
	new_line=0;
	BEGIN INITIAL;

}
<MulticommentState>\r {
	multi_comment+="\r";
	//new_line++;

}
<MulticommentState>\n {
	new_line++;
	multi_comment+="\n";
	
}
<MulticommentState>. {
	multi_comment+=yytext[0];
	
}

. {
	error_counter++;
	logout<<"Error at line# "<< line_count <<": UNRECOGNIZED_CHAR "<<yytext<<"\n";
}
%%



int main(int argc,char *argv[])
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
	
	//logout= fopen("log.txt","w");
	//tokenout= fopen("token.txt","w");

   // logout.open("2005083_log.txt");
   logout.open("2005083_log.txt");
    tokenout.open("2005083_token.txt");
	symTable.Enter_scope(10, logout);
    yyin= fin;
	yylex();
	
	
	


	fclose(yyin);
	symTable.Exit_scope(logout,10);

	symTable.Print_All_Scope_tables(logout);
	logout<<"Total lines: "<<line_count<<endl;
	logout<<"Total errors: "<<error_counter<<endl;
	logout<<"Total warnings: "<<warnings<<endl;
	tokenout.close();
	logout.close();
    return 0;

}
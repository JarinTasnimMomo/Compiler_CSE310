%{
#include<bits/stdc++.h>

#include "2005083.cpp"
//#define YYSTYPE SymbolInfo*

using namespace std;

int yyparse(void);
int yylex(void);
extern FILE *yyin;
SymbolTable symboltable;

SymbolInfo *current;
int line_count=1;
int error_counter=0;
vector<SymbolInfo*> *children; 
ofstream errorout;
ofstream logout;
string str;

bool check_float;


void print_to_log1(const char* name, const char* tex)
{
	logout<<"Line# "<<line_count<<": Token <"<<name<<"> Lexeme "<<tex<<" found\n";
	

}
void print_to_log2(const char* text, const char* text1)
{
	logout<<text<<" : "<<text1<<" "<<endl;
	

}
void check_multiple_declaration_param(vector<SymbolInfo*> *sym)
{
	vector<string> pnames;
	for(int i=0;i<sym->size();i++)
	{
		
		if(sym->at(i)->get_Type()!="VOID"||sym->at(i)->get_Type()!="INT"||sym->at(i)->get_Type()!="FLOAT"||sym->at(i)->get_Type()!="COMMA")
		{
				pnames.push_back(sym->at(i)->get_Name());
		}
	for(int k=0;k<pnames.size();k++)
	{
		if(sym->at(i)->get_Name()==pnames[k])
		{
			error_counter++;
			errorout<<"Line# "<<line_count<<": Redefinition of parameter"<<pnames[k]<<endl;
		}
	}
	}
	pnames.clear();
	
}

void set_children(vector<SymbolInfo*> *p)
{
	children=new vector<SymbolInfo*>;
	for(int i=0;i<p->size();i++)
	{
		children->push_back(p->at(i));
	}
}

void yyerror(const char *s)
{
	//write your code
	logout<<"line# "<<line_count<<": Syntax Error"<<endl;
	errorout<<"line# "<<line_count<<": Syntax Error"<<endl;
	error_counter++;

}


%}

%union{
	SymbolInfo * symbol;
	vector <SymbolInfo*> *symbolList;
	
}

%token<symbol> IF ELSE FOR WHILE DO BREAK INT CHAR FLOAT DOUBLE VOID RETURN CASE DEFAULT CONTINUE LPAREN RPAREN 
%token<symbol> LCURL RCURL LTHIRD RTHIRD MULOP INCOP ADDOP RELOP DECOP BITOP NOT SEMICOLON COMMA LOGICOP ASSIGNOP CONST_INT CONST_FLOAT ID PRINTLN
%type<symbol> type_specifier
%type<symbolList>program func_declaration func_definition parameter_list unit compound_statement var_declaration declaration_list  
%type<symbolList>statements statement expression_statement variable expression logic_expression rel_expression unary_expression factor simple_expression term
%type<symbolList> argument_list arguments

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%%

start : program
	{
		//write your code in this block in all the similar blocks below
		//logout<<"start : program"<<endl;
		print_to_log2("start", "program");
		



	}
	;

program : program unit 
         {
			print_to_log2("program", "program unit");
			//logout<<"program : program Unit"<<endl;
			$$=new vector<SymbolInfo*>();
			for(int i=0;i<$1->size();i++)
			{
				$$->push_back($1->at(i));
			}
			for(int i=0;i<$2->size();i++)
			{
				$$->push_back($2->at(i));
			}
        }
	| unit
		{
			print_to_log2("program", "unit");
			$$=new vector<SymbolInfo*>();
			for(int i=0;i<$1->size();i++)
			{
				$$->push_back($1->at(i));
			}
		}
	;
	
unit : var_declaration
		{
			print_to_log2("unit", "var_declaration");
			$$=new vector<SymbolInfo*>();
			for(int i=0;i<$1->size();i++)
			{
				$$->push_back($1->at(i));
			}
			
		}
     | func_declaration
	 	{
			print_to_log2("unit", "func_declaration");
			$$=new vector<SymbolInfo*>();
			for(int i=0;i<$1->size();i++)
			{
				$$->push_back($1->at(i));
			}
		}
     | func_definition
	 {
		print_to_log2("unit", "func_defination");
		$$=new vector<SymbolInfo*>();
			for(int i=0;i<$1->size();i++)
			{
				$$->push_back($1->at(i));
			}
	 }
     ;
     
func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON
					{
						print_to_log2("func_declaration","type_specifier ID LPAREN parameter_list RPAREN SEMICOLON");
						//str.clear();

						//str=$1->get_Name()+$2->get_Name() + $3->get_Name()+ $4->get_Name()+$5->get_Name()+$6->get_Name();

						$$=new vector <SymbolInfo*>();
						
						if(symboltable.Insert($2->get_Name(),$2->get_Type(),logout)==false)
						{
							error_counter++;
							errorout<<"Error at line#"<<line_count<<"multiple declaration of "<<$2->get_Name()<<endl;
						}
						else{
							SymbolInfo *temp;
							vector<string> paramname;
							temp=symboltable.Look_up($2->get_Name());
							temp->set_rtype($1->get_Type());
							check_multiple_declaration_param($4);
							temp->set_parameter_counter($4->size());
							temp->set_plist($4);
							temp->set_isfunction(true);
							$$->push_back($1);
							$$->push_back($2);
							$$->push_back($3);
							for(int i=0;i<$4->size();i++)
							{
								$$->push_back($4->at(i));
								//children->push_back($4->at(i));
								//paramname.push_back($4->at(i)->get_Name());
							}
							$$->push_back($5);
							$$->push_back($6);
							

						}

						}
					//children->clear();

					
		| type_specifier ID LPAREN RPAREN SEMICOLON
			{
						print_to_log2("func_declaration","type_specifier ID LPAREN RPAREN SEMICOLON");
						str.clear();
						//str=$1->get_Name()+$2->get_Name()+"();";

						$$=new vector<SymbolInfo*>();
						$2->set_isfunction(true);
						$2->set_rtype($1->get_Type());
						
						
						if(symboltable.Insert_helper($2,logout)==false)
						{
							error_counter++;
							errorout<<"Error at line#"<<line_count<<"multiple declaration of "<<$2->get_Name()<<endl;
						}
						else{
							//SymbolInfo *temp;
							//temp=symboltable.Look_up($2->get_Name());
							//temp->set_rtype($1->get_Type());
							
							
							//temp->set_isfunction(true);
							$$->push_back($1);
							$$->push_back($2);
							$$->push_back($3);
							$$->push_back($4);
							$$->push_back($5);

							

						}
					

			}
		;
		 
func_definition : type_specifier ID LPAREN parameter_list RPAREN
					{
						
						print_to_log2("func_definition","type_specifier ID LPAREN parameter_list RPAREN compound_statement");
						//$$=new vector <SymbolInfo*> ();
						current=symboltable.Look_up($2->get_Name());
						if(current==nullptr)
						{	
								check_multiple_declaration_param($4);
								SymbolInfo *s=new SymbolInfo($2->get_Name(),"ID");
								s->set_plist($4);
								s->set_isfunction(true);
								s->set_isDefi(true);
								s->set_rtype($1->get_Type());
								
								if(!symboltable.Insert_helper(s, logout))
								{
									cout<<"errpoor!";
								}
								
								current=symboltable.Look_up($2->get_Name());
								

								

						}

						set_children($4);
					}
					compound_statement{
						symboltable.Print_All_Scope_tables(logout);
						symboltable.Exit_scope(logout,3);
					
					}
					{
						$$=new vector<SymbolInfo*>();
						$$->push_back($1);
						$$->push_back($2);
						$$->push_back($3);
						for(int i=0;i<$4->size();i++)
						{
							$$->push_back($4->at(i));

						}
						$$->push_back($5);
						for(int i=0;i<$7->size();i++)
						{
							$$->push_back($7->at(i));

						}

					children->clear();


					}
		| type_specifier ID LPAREN RPAREN
			{
				print_to_log2("func_definition","type_specifier ID LPAREN RPAREN compound_statement");
				current=symboltable.Look_up($2->get_Name());
						if(current==nullptr)
						{
								SymbolInfo *s=new SymbolInfo($2->get_Name(),"ID");
								s->set_isfunction(true);
								s->set_isDefi(true);
								s->set_rtype($1->get_Type());
								//symboltable.Insert_helper(s);
								
								if(!symboltable.Insert_helper(s,logout))
							{
								cout<<"Error at insertion!"<<endl;
							}
								


						}

			} compound_statement{
				//symboltable.Print_All_Scope_tables(logout);
				symboltable.Exit_scope(logout,3);
			}
			{
				$$=new vector<SymbolInfo*>();
				$$->push_back($1);
						$$->push_back($2);
						$$->push_back($3);
						$$->push_back($4);
						for(int i=0;i<$6->size();i++)
						{
							$$->push_back($6->at(i));

						}
			}
 		;				


parameter_list  : parameter_list COMMA type_specifier ID
					{
						print_to_log2("parameter_list", "parameter_list COMMA type_specifier ID");
						$$=new vector<SymbolInfo*>();
						for(int i=0;i<$1->size();i++)
						{
							$$->push_back($1->at(i));
						}
						$$->push_back($2);
						$$->push_back($3);
						$$->push_back($4);


					}
		| parameter_list COMMA type_specifier
		{
		print_to_log2("parameter_list", "parameter_list COMMA type_specifier");
		$$=new vector<SymbolInfo*>();
						for(int i=0;i<$1->size();i++)
						{
							$$->push_back($1->at(i));
						}
						$$->push_back($2);
						$$->push_back($3);
						;
		}
 		| type_specifier ID
		{
			print_to_log2("parameter_list", " type_specifier ID");
			$$=new vector<SymbolInfo*>();
					
						$$->push_back($1);
						$$->push_back($2);
						
		}
		| type_specifier
		{
			print_to_log2("parameter_list", "type_specifier");
			$$=new vector<SymbolInfo*>();
					
						$$->push_back($1);
		}
 		;

 		
compound_statement : LCURL
					{
						//cout << "even before log" << endl;
						//print_to_log2("compound_statement", " LCURL statements RCURLr");
						//cout << "before enter scope" << endl;
						
						symboltable.Enter_scope(11, logout);
						//cout << "after enter scope" << endl;
						//cout << children << endl;
						for(int i=0;i<children->size();i++)
						{
							//cout << i << endl;
							
							if(!symboltable.Insert_helper(children->at(i),logout))
							{
								//cout << "inside condition" << endl;
								//cout<<"Error at insertion!"<<endl;
								error_counter++;
							}
							
							//cout << "outside condition" << endl;
						}
						//cout << "after loop" << endl;
						
					} statements RCURL{	
						print_to_log2("compound_statement", " LCURL statements RCURL");
						$$=new vector<SymbolInfo*>();
						$$->push_back($1);
						for(int i=0;i<$3->size();i++)
						{	

							$$->push_back($3->at(i));
						}
						$$->push_back($4);
						symboltable.Print_All_Scope_tables(logout);
						symboltable.Exit_scope(logout,3);

					}
 		    | LCURL RCURL
			{
				print_to_log2("compound_statement", " LCURL RCURLr");
				$$=new vector<SymbolInfo*>();
						symboltable.Enter_scope(11, logout);
						$$->push_back($1);
						$$->push_back($2);
						
						symboltable.Print_All_Scope_tables(logout);
						symboltable.Exit_scope(logout,3);
			}
 		    ;
 		    
var_declaration : type_specifier declaration_list SEMICOLON
					{
						print_to_log2("var_declaration", "type_specifier declaration_list SEMICOLON");
						$$=new vector<SymbolInfo*>();
						if($1->get_Type()!="VOID")
						{
							$$->push_back($1);
						for(int i=0;i<$2->size();i++)
						{
							$$->push_back($2->at(i));
						}
						$$->push_back($3);

						}
					}
 		 ;
 		 
type_specifier	: INT 
					{
							print_to_log2("type_specifier", "INT");
							//print_to_log1("INT",$1->get_Name());
							cout<<"type\n";
							cout<<$1->get_Type();
							$$=$1;
					}

 		| FLOAT
		{
			print_to_log2("type_specifier", "FLOAT");
			//print_to_log1($1->get_Type(), $1->get_Name());
			$$=$1;
		}
 		| VOID
		{
			print_to_log2("type_specifier", "VOID");
			//print_to_log1($1->get_Type(), $1->get_Name());
			$$=$1;
		}
 		;
 		
declaration_list : declaration_list COMMA ID
					{
						print_to_log2("declaration_list", "declaration_list COMMA ID");
						$$=new vector<SymbolInfo*>();
						
						if(!symboltable.Insert($3->get_Name(),$3->get_Type(),logout))
						{
							cout<<"insertion error!";
						}
						
						for(int i=0;i<$1->size();i++)
						{
							$$->push_back($1->at(i));
						}
						$$->push_back($2);
						$$->push_back($3);


					}

 		  | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD
		  {
			print_to_log2("declaration_list", "declaration_list COMMA ID LTHIRD CONST_INT RTHIRD");
			$3->set_isarray(true);
			$$=new vector<SymbolInfo*>();
					
						if(!symboltable.Insert($3->get_Name(),$3->get_Type(),logout))
						{
							cout<<"insertion error!";
						}
					
						for(int i=0;i<$1->size();i++)
						{
							$$->push_back($1->at(i));
						}
						$$->push_back($2);
						$$->push_back($3);
						$$->push_back($4);
						$$->push_back($5);
						$$->push_back($6);



		  }
 		  | ID
		  	{
				print_to_log2("declaration_list", "ID");
				//print_to_log1($1->get_Name(), $1->get_Type());
				$$=new vector<SymbolInfo*>();
				
						if(!symboltable.Insert($1->get_Name(),$1->get_Type(),logout))
						{
							cout<<"insertion error!\n";
							cout<<$1->get_Name();
						}
					
				$$->push_back($1);

			}
 		  | ID LTHIRD CONST_INT RTHIRD
		  {
			print_to_log2("declaration_list", "ID LTHIRD CONST_INT RTHIRD");
			//print_to_log1($1->get_Name(), $1->get_Type());
			$$=new vector<SymbolInfo*>();
			$3->set_isarray(true);
					
						if(!symboltable.Insert_helper($3,logout))
						{
							cout<<"insertion error!";
						}
					
				$$->push_back($1);
				$$->push_back($2);
				$$->push_back($3);
				$$->push_back($4);
		  }
 		  ;
 		  
statements : statement
			{
				print_to_log2("statements","statement");
				$$=new vector <SymbolInfo*>();
				for(int i=0;i<$1->size();i++)
				{
					$$->push_back($1->at(i));
				}
			}
	   | statements statement
	   {
			print_to_log2("statements","statements statement");
			$$=new vector <SymbolInfo*>();
				for(int i=0;i<$1->size();i++)
				{
					$$->push_back($1->at(i));
				}
			
				for(int i=0;i<$2->size();i++)
				{
					$$->push_back($2->at(i));
				}	
	   }
	   ;
	   
statement : var_declaration
			{
				print_to_log2("statement","var_declaration");
				$$=new vector <SymbolInfo*>();
				for(int i=0;i<$1->size();i++)
				{
					$$->push_back($1->at(i));
				}
				
			}
	  | expression_statement
	  {
		print_to_log2("statement","expression_statement");
		$$=new vector <SymbolInfo*>();
				for(int i=0;i<$1->size();i++)
				{
					$$->push_back($1->at(i));
				}
	  }
	  | compound_statement
	  {
		symboltable.Enter_scope(11,logout);
		$$=new vector <SymbolInfo*>();
				for(int i=0;i<$1->size();i++)
				{
					$$->push_back($1->at(i));
				}
	  
	  
		print_to_log2("statement","compound_statement");
		symboltable.Print_All_Scope_tables(logout);
		symboltable.Exit_scope(logout,3);

	  }
	  | FOR LPAREN expression_statement expression_statement expression RPAREN statement
	  {
		print_to_log2("statement","FOR LPAREN expression_statement expression_statement expression RPAREN statement");
		$$=new vector <SymbolInfo*>();
		$$->push_back($1);
		$$->push_back($2);
				for(int i=0;i<$3->size();i++)
				{
					$$->push_back($3->at(i));
				}
				for(int i=0;i<$4->size();i++)
				{
					$$->push_back($4->at(i));
				}
				for(int i=0;i<$5->size();i++)
				{
					$$->push_back($5->at(i));
				}
		$$->push_back($6);
				for(int i=0;i<$7->size();i++)
				{
					$$->push_back($7->at(i));
				}		

	  }
	  | IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE
	  {
		print_to_log2("statement","IF LPAREN expression RPAREN statement");
		$$=new vector <SymbolInfo*>();
		$$->push_back($1);
		$$->push_back($2);

				for(int i=0;i<$3->size();i++)
				{
					$$->push_back($3->at(i));
				}
		$$->push_back($4);
		for(int i=0;i<$5->size();i++)
				{
					$$->push_back($5->at(i));
				}

	  }
	  | IF LPAREN expression RPAREN statement ELSE statement
	  {
		print_to_log2("statement","IF LPAREN expression RPAREN statement ELSE statement");
		$$=new vector <SymbolInfo*>();
		$$->push_back($1);
		$$->push_back($2);

				for(int i=0;i<$3->size();i++)
				{
					$$->push_back($3->at(i));
				}
		$$->push_back($4);
		for(int i=0;i<$5->size();i++)
				{
					$$->push_back($5->at(i));
				}
		$$->push_back($6);
		for(int i=0;i<$7->size();i++)
				{
					$$->push_back($7->at(i));
				}		


	  }
	  | WHILE LPAREN expression RPAREN statement
	  {
		print_to_log2("statement","WHILE LPAREN expression RPAREN statement");
		$$=new vector <SymbolInfo*>();
		$$->push_back($1);
		$$->push_back($2);

				for(int i=0;i<$3->size();i++)
				{
					$$->push_back($3->at(i));
				}
		$$->push_back($4);
		for(int i=0;i<$5->size();i++)
				{
					$$->push_back($5->at(i));
				}


	  }
	  | PRINTLN LPAREN ID RPAREN SEMICOLON
	  {
		print_to_log2("statement","PRINTLN LPAREN ID RPAREN SEMICOLON");
		$$=new vector<SymbolInfo*>();
		$$->push_back($1);
		$$->push_back($2);
		$$->push_back($3);
		$$->push_back($4);
		$$->push_back($5);

	  }
	  | RETURN expression SEMICOLON
	  {
		print_to_log2("statement","RETURN expression SEMICOLON");
		$$=new vector<SymbolInfo*>();
		cout << "1";
		$$->push_back($1);
		cout << "2";
		for(int i=0;i<$2->size();i++)
		{
			$$->push_back($2->at(i));
		}
		$$->push_back($3);
		cout<<$3->get_Name();
	  }
	  ;
	  
expression_statement 	: SEMICOLON	
						{
							print_to_log2("expression_statement", "SEMICOLON");
							$$=new vector<SymbolInfo*>();
							$$->push_back($1);
							cout<<"semicolon";
						}
		
			| expression SEMICOLON 
			{
				print_to_log2("expression_statement", "expression SEMICOLON");
				$$=new vector<SymbolInfo*>();
				for(int i=0;i<$1->size();i++)
			{
					$$->push_back($1->at(i));
			}
				
				$$->push_back($2);
			}
			;
	  
variable : ID 	
			{
				print_to_log2("variable", "ID");
				$$=new vector<SymbolInfo*>();
				SymbolInfo *curr=symboltable.Look_up($1->get_Name());
				if(curr==nullptr)
				{
					cout<<"err!";
					error_counter++;

					errorout<<"Line no#"<<line_count<<"Undeclared variable."<<$1->get_Name()<<endl;
				}
				//print_to_log1($1->get_Type(),$1->get_Name());
				$$->push_back($1);

			}	
	 | ID LTHIRD expression RTHIRD 
	 {
		print_to_log2("variable", "ID LTHIRD expression RTHIRD");
		$$=new vector<SymbolInfo*>();
				SymbolInfo *curr=symboltable.Look_up($1->get_Name());
				if(curr==nullptr)
				{
					cout<<"err!";
					error_counter++;

					errorout<<"Line no#"<<line_count<<"Undeclared variable."<<$1->get_Name()<<endl;
				}
				if(strcmp($3->at(0)->get_Type(),"CONST_INT")==0)
				{
				//print_to_log1($1->get_Type(),$1->get_Name());
				}
				else{
					cout<<"err!";
					error_counter++;

					errorout<<"Line no#"<<line_count<<"Expression is not an integer!"<<$1->get_Name()<<endl;
				}
				$$->push_back($1);
				$$->push_back($2);
				$$->push_back($3->at(0));
				$$->push_back($4);


	 }
	 ;
	 
 expression : logic_expression	
				{
					print_to_log2("expression", "logic_expression");
					cout<<"here1";
					$$=new vector<SymbolInfo*>();
					for(int i=0;i<$1->size();i++)
					{
						$$->push_back($1->at(i));

					}

				}
	   | variable ASSIGNOP logic_expression 
	   {
		print_to_log2("expression", "variable ASSIGNOP logic_expression");
		$$=new vector<SymbolInfo*>();
					for(int i=0;i<$1->size();i++)
					{
						$$->push_back($1->at(i));

					}
					$$->push_back($2);

					for(int i=0;i<$3->size();i++)
					{
						$$->push_back($3->at(i));

					}

	   }	
	   ;
			
logic_expression : rel_expression 	
					{
						print_to_log2("logic_expression", "rel_expression");
					$$=new vector<SymbolInfo*>();
					for(int i=0;i<$1->size();i++)
					{
						$$->push_back($1->at(i));

					}

					}
		 | rel_expression LOGICOP rel_expression 	
		 {
			print_to_log2("logic_expression", "rel_expression LOGICOP rel_expression");
			$$=new vector<SymbolInfo*>();
					for(int i=0;i<$1->size();i++)
					{
						$$->push_back($1->at(i));

					}
					$$->push_back($2);

					for(int i=0;i<$3->size();i++)
					{
						$$->push_back($3->at(i));

					}
		 }
		 ;
			
rel_expression	: simple_expression 
				{
					print_to_log2("rel_expression", "simple_expression");
					$$=new vector<SymbolInfo*>();
					for(int i=0;i<$1->size();i++)
					{
						$$->push_back($1->at(i));

					}

				}
		| simple_expression RELOP simple_expression	
		{
			print_to_log2("rel_expression", "simple_expression RELOP simple_expression");
			$$=new vector<SymbolInfo*>();
					for(int i=0;i<$1->size();i++)
					{
						$$->push_back($1->at(i));

					}
					$$->push_back($2);

					for(int i=0;i<$3->size();i++)
					{
						$$->push_back($3->at(i));

					}

		}
		;
				
simple_expression : term 
					{
						print_to_log2("simple_expression", "term");
					$$=new vector<SymbolInfo*>();
					for(int i=0;i<$1->size();i++)
					{
						$$->push_back($1->at(i));

					}
					
					}
		  | simple_expression ADDOP term 
		  {
			print_to_log2("simple_expression", "simple_expression ADDOP term");
			$$=new vector<SymbolInfo*>();
					for(int i=0;i<$1->size();i++)
					{
						$$->push_back($1->at(i));

					}
					$$->push_back($2);

					for(int i=0;i<$3->size();i++)
					{
						$$->push_back($3->at(i));

					}


		  }
		  ;
					
term :	unary_expression
		{
			print_to_log2("term", "unary_expression");
			$$=new vector<SymbolInfo*>();
					for(int i=0;i<$1->size();i++)
					{
						$$->push_back($1->at(i));

					}

		}
     |  term MULOP unary_expression
	 
	 {
		print_to_log2("term", "term MULOP unary_expression");
		$$=new vector<SymbolInfo*>();
					for(int i=0;i<$1->size();i++)
					{
						$$->push_back($1->at(i));

					}
					$$->push_back($2);

					for(int i=0;i<$3->size();i++)
					{
						$$->push_back($3->at(i));

					}
	 }
     ;

unary_expression : ADDOP unary_expression  
				{
					print_to_log2("unary_expression", "ADDOP unary_expression");
					$$=new vector<SymbolInfo*>();
					$$->push_back($1);
					for(int i=0;i<$2->size();i++)
					{
						$$->push_back($2->at(i));
					}
				}
		 | NOT unary_expression 
		 {
			print_to_log2("unary_expression", "NOT unary_expression");
			$$=new vector<SymbolInfo*>();
					$$->push_back($1);
					for(int i=0;i<$2->size();i++)
					{
						$$->push_back($2->at(i));
					}

		 }
		 | factor 
		 {
			print_to_log2("unary_expression", "factor");
			$$=new vector<SymbolInfo*>();
					for(int i=0;i<$1->size();i++)
					{
						$$->push_back($1->at(i));

					}

		 }
		 ;
	
factor	: variable 
		{
			print_to_log2("factor", "variable");
			$$=new vector<SymbolInfo*>();
					for(int i=0;i<$1->size();i++)
					{
						$$->push_back($1->at(i));

					}
		}
	| ID LPAREN argument_list RPAREN
	{
		print_to_log2("factor", "ID LPAREN argument_list RPAREN");
		vector<string> functions_param;
		vector<SymbolInfo*> *parameters;

		SymbolInfo *s=symboltable.Look_up($1->get_Name());
		parameters=s->get_plist();

		if(s==nullptr)
		{	
			cout<<"error";
			error_counter++;

			logout<<"Line no#"<<line_count<<"Undeclared\n";

		}
		else{
			if(!s->check_isfunction())
			{
				cout<<"error";
			error_counter++;

			logout<<"Line no#"<<line_count<<"Is not a function\n";
			}
			else
			{
				for(int i=0;i<parameters->size();i++)
				{
					if(parameters->at(i)->get_Type()!="ID"&&parameters->at(i)->get_Type()!="COMMA")
					{
						functions_param.push_back(parameters->at(i)->get_Name());
					}
					vector<string> argues;
					for(int i=0;i<$3->size();i++)
					{
						while(i<$3->size()&&($3->at(i)->get_Name()!=","))
						{
								if($3->at(i)->get_Type()=="ID")
								{
									if($3->at(i)->get_vtype()=="FLOAT")
									{
										check_float=true;
									}
								}
								else
								{
									if($3->at(i)->get_Type()=="CONST_FLOAT")
									{
										check_float=true;
									}
								}
								i++;
						}
						if(check_float){
							argues.push_back("FLOAT");

						}
						else{
							argues.push_back("INT");
						}
					}
					if(argues.size()!=functions_param.size())
					{
						cout<<"error";
						error_counter++;

						errorout<<"Line no#"<<line_count<<"function parameter mismatch\n";
					}
				}
			}

		}
		$$=new vector<SymbolInfo*>();
		$$->push_back($1);
		$$->push_back($2);
		for(int i=0;i<$3->size();i++)
		{
			$$->push_back($3->at(i));
		}
		$$->push_back($4);


	}
	| LPAREN expression RPAREN
	{
		print_to_log2("factor", "LPAREN expression RPAREN");
		$$=new vector<SymbolInfo*>();
		$$->push_back($1);
		
		for(int i=0;i<$2->size();i++)
		{
			$$->push_back($2->at(i));
		}
		$$->push_back($3);

	}
	| CONST_INT 
	{
		print_to_log2("factor", "CONST_INT");
		$$=new vector<SymbolInfo*>();
		$$->push_back($1);
	}
	| CONST_FLOAT
	{
		print_to_log2("factor", "CONST_FLOAT");
		$$=new vector<SymbolInfo*>();
		$$->push_back($1);
	}
	| variable INCOP 
	{print_to_log2("factor", "variable INCOP");
	$$=new vector<SymbolInfo*>();
		
		for(int i=0;i<$1->size();i++)
		{
			$$->push_back($1->at(i));
		}
		$$->push_back($2);
	
	}
	| variable DECOP
	{
		print_to_log2("factor", "variable DECOP");
		$$=new vector<SymbolInfo*>();
		
		for(int i=0;i<$1->size();i++)
		{
			$$->push_back($1->at(i));
		}
		$$->push_back($2);
	}
	;
	
argument_list : arguments
				{
					print_to_log2("argument_list", "arguments");
					$$=new vector<SymbolInfo*>();
		
					for(int i=0;i<$1->size();i++)
					{
							$$->push_back($1->at(i));
					}
				}
			  
			  ;
	
arguments : arguments COMMA logic_expression
			{
				print_to_log2("arguments","arguments COMMA logic_expression");
				$$=new vector<SymbolInfo*>();
		
					for(int i=0;i<$1->size();i++)
					{
							$$->push_back($1->at(i));
					}

					$$->push_back($2);

					for(int i=0;i<$3->size();i++)
					{
							$$->push_back($3->at(i));
					}

			}
	      | logic_expression
		  {
			print_to_log2("arguments","logic_expression");
			$$=new vector<SymbolInfo*>();
		
					for(int i=0;i<$1->size();i++)
					{
							$$->push_back($1->at(i));
					}
		  }

	      ;
 

%%
int main(int argc,char *argv[])
{

	/*if((fp=fopen(argv[1],"r"))==NULL)
	{
		printf("Cannot Open Input File.\n");
		exit(1);
	}

	fp2= fopen(argv[2],"w");
	fclose(fp2);
	fp3= fopen(argv[3],"w");
	fclose(fp3);
	
	fp2= fopen(argv[2],"a");
	fp3= fopen(argv[3],"a");
	

	yyin=fp;*/
	if (argc != 2) {
		std::cout << "Wrong usage" << std::endl;
		return 1;
	}

	yyin = fopen(argv[1], "r");
	if (!yyin) {
		std::cout << "File not found" << std::endl;
		return 1;
	}
	logout.open("2005083_log.txt");
	errorout.open("2005083_error.txt");

	yyparse();

	fclose(yyin);
	//symboltable.Enter_scope(11,logout);
	//symboltable.Print_All_Scope_tables(logout);
	logout<<"Total Lines: "<<line_count<<endl;

	//fclose(fp2);
	//fclose(fp3);
	logout.close();
	errorout.close();
	
	return 0;
}


%{
#include<bits/stdc++.h>

#include "2005083.cpp"
#include "2005083_assembly_generator.cpp"
//#define YYSTYPE SymbolInfo*

using namespace std;

int yyparse(void);
int yylex(void);
extern FILE *yyin;
SymbolTable symboltable;

// SymbolInfo *current;
extern int line_count;
extern int error_counter;
vector<SymbolInfo*> *children_Arg; 
vector<SymbolInfo*> params;
ofstream errorout;
ofstream logout;
ofstream parseout;
ofstream assembly_out;

string str_for_data_type="";

bool check_float;


void parser_pri(SymbolInfo *node)
{
	parseout<<node->get_Name()<<" : "<<node->get_Type()<< "	       <Line: "<<node->get_start_line()<<"-"<<node->get_end_line()<<">\n";
}
void print_to_parser(SymbolInfo *s, int depth)
{
	
	
    for(int i=0;i<depth;i++)
	{
		parseout<<" ";
	}

	parser_pri(s);
	
	
	    

		for(int k=0; k<s->get_children_size();k++)
		{
			
			print_to_parser(s->get_child_At_fixed_position(k),depth+1);
		}
    

}


void print_to_log2(const char* text, const char* text1)
{
	logout<<text<<" : "<<text1<<" "<<endl;
	

}

// void check_multiple_declaration_param(vector<SymbolInfo*> *sym)
// {
// 	vector<string> pnames;
// 	for(int i=0;i<sym->size();i++)
// 	{
		
// 		if(sym->at(i)->get_Type()!="VOID"||sym->at(i)->get_Type()!="INT"||sym->at(i)->get_Type()!="FLOAT"||sym->at(i)->get_Type()!="COMMA")
// 		{
// 				pnames.push_back(sym->at(i)->get_Name());
// 		}
// 	for(int k=0;k<pnames.size();k++)
// 	{
// 		if(sym->at(i)->get_Name()==pnames[k])
// 		{
// 			error_counter++;
// 			errorout<<"Line# "<<line_count<<": Redefinition of parameter"<<pnames[k]<<endl;
// 		}
// 	}
// 	}
// 	pnames.clear();
	
// }

/*void set_children(vector<SymbolInfo*> *p)
{
	children=new vector<SymbolInfo*>;
	for(int i=0;i<p->size();i++)
	{
		children->push_back(p->at(i));
	}
}*/

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
	
	
}

%token<symbol> IF ELSE FOR WHILE DO BREAK INT CHAR FLOAT DOUBLE VOID RETURN CASE DEFAULT CONTINUE LPAREN RPAREN 
%token<symbol> LCURL RCURL LTHIRD RTHIRD MULOP INCOP ADDOP RELOP DECOP BITOP NOT SEMICOLON COMMA LOGICOP ASSIGNOP CONST_INT CONST_FLOAT ID PRINTLN
%type<symbol> type_specifier
%type<symbol> start program func_declaration func_definition parameter_list unit compound_statement var_declaration declaration_list  
%type<symbol>statements statement expression_statement variable expression logic_expression rel_expression unary_expression factor simple_expression term
%type<symbol> argument_list arguments

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%%

start : program
	{
		//cout<<"r1"<<endl;
		//write your code in this block in all the similar blocks below
		//logout<<"start : program"<<endl;
		print_to_log2("start", "program");
		$$=new SymbolInfo("start", "program");
        $$->addChildren($1);
        $$->set_start_line($1->get_start_line());
        $$->set_end_line($1->get_end_line());
		print_to_parser($$,0);
		//delete symboltable;
		



	}
	;

program : program unit 
         {  //cout<<"r2"<<endl;
			print_to_log2("program", "program unit");
			//logout<<"program : program Unit"<<endl;
			$$=new SymbolInfo( "program","program unit");
			$$->addChildren($1);
            $$->addChildren($2);
            $$->set_start_line($1->get_start_line());
            $$->set_end_line($2->get_end_line());
			
        }
	| unit
		{//cout<<"r3"<<endl;
			print_to_log2("program", "unit");
			$$=new SymbolInfo( "program","unit");
            $$->addChildren($1);
            $$->set_start_line($1->get_start_line());
            $$->set_end_line($1->get_end_line());
		}
	;
	
unit : var_declaration
		{//cout<<"r4"<<endl;
			print_to_log2("unit", "var_declaration");
			$$=new SymbolInfo("unit", "var_declaration");
            $$->addChildren($1);
            $$->set_start_line($1->get_start_line());
            $$->set_end_line($1->get_end_line());
			
		}
     | func_declaration
	 	{//cout<<"r5"<<endl;
			print_to_log2("unit", "func_declaration");
            $$=new SymbolInfo("unit", "func_declaration");
            $$->addChildren($1);
            $$->set_start_line($1->get_start_line());
            $$->set_end_line($1->get_end_line());
			
		}
     | func_definition
	 {//cout<<"r6"<<endl;
		print_to_log2("unit", "func_defination");
		$$=new SymbolInfo("unit", "func_definition");
            $$->addChildren($1);
            $$->set_start_line($1->get_start_line());
            $$->set_end_line($1->get_end_line());
	 }
     ;
     
func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON
					{//cout<<"r7"<<endl;
						print_to_log2("func_declaration","type_specifier ID LPAREN parameter_list RPAREN SEMICOLON");
                        $$=new SymbolInfo("func_declaration","type_specifier ID LPAREN parameter_list RPAREN SEMICOLON");
                        $$->addChildren($1);
                        $$->set_start_line($1->get_start_line());
                        $$->addChildren($2);
                        $3->set_start_line(line_count);
                        $3->set_end_line(line_count);
                        $$->addChildren($3);
                        $$->addChildren($4);
                        $5->set_start_line(line_count);
                        $5->set_end_line(line_count);
                        $$->addChildren($5);
                        $$->addChildren($6);
                        if(!symboltable.Insert($2->get_Name(), $2->get_Type()))
                        {
                            cout<<"Error at insertion!"<<endl;
                        }
                        $2->set_parameter_counter(params.size());
                        $2->set_rtype($1->get_Name());
						


						$$->set_end_line($6->get_end_line());



						params.clear();

					}
					//children->clear();

					
		| type_specifier ID LPAREN RPAREN SEMICOLON
			{//cout<<"r8"<<endl;
						print_to_log2("func_declaration","type_specifier ID LPAREN RPAREN SEMICOLON");
                        $$=new SymbolInfo("func_declaration","type_specifier ID LPAREN RPAREN SEMICOLON");
                        $$->addChildren($1);
                        $$->set_start_line($1->get_start_line());
                        $$->addChildren($2);
                        $3->set_start_line(line_count);
                        $3->set_end_line(line_count);
                        $$->addChildren($3);
                        
                        $4->set_start_line(line_count);
                        $4->set_end_line(line_count);
                        $$->addChildren($4);
                        $$->addChildren($5);
                        if(!symboltable.Insert($2->get_Name(), $2->get_Type()))
                        {
                            cout<<"Error at insertion!"<<endl;
                        }
						


						$$->set_end_line($5->get_end_line());
                        $2->set_parameter_counter(params.size());
                        $2->set_rtype($1->get_Name());



						
						
					

			}
		;
		 
func_definition : type_specifier ID LPAREN parameter_list RPAREN
					{//cout<<"r9"<<endl;
						
						print_to_log2("func_definition","type_specifier ID LPAREN parameter_list RPAREN compound_statement");
						//$$=new vector <SymbolInfo*> ();

						/*
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

						set_children($4);*/

						symboltable.Insert($2->get_Name(), $2->get_Type());
						$2->set_rtype($1->get_Name());
						$2->set_parameter_counter(params.size());


					}
					compound_statement{cout<<"r10"<<endl;


						$$=new SymbolInfo("func_definition","type_specifier ID LPAREN parameter_list RPAREN compound_statement");
						$3->set_start_line(line_count);
						$$->addChildren($1);
						$$->addChildren($2);
						$3->set_end_line(line_count);
						$$->addChildren($3);
						$$->addChildren($4);
						$5->set_start_line(line_count);
						$5->set_end_line(line_count);
						$$->addChildren($5);
						int parameter_count=params.size();
						for(int i=0;i<parameter_count;i++)
						{
							SymbolInfo *temp=params.at(i);
							SymbolInfo* temp2=symboltable.Look_up($2->get_Name());
							temp2->add_parameter(temp->get_Name());
						}

						$$->set_start_line($1->get_start_line());
						$$->addChildren($7);


						$$->set_end_line($7->get_end_line());
						params.clear();

						symboltable.Print_All_Scope_tables(logout);
						symboltable.Exit_scope(logout,3);
					
					}
					/* {
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

					//children->clear();


					} */
		| type_specifier ID LPAREN RPAREN
			{//cout<<"r11"<<endl;
				print_to_log2("func_definition","type_specifier ID LPAREN RPAREN compound_statement");
				symboltable.Insert($2->get_Name(), $2->get_Type());
					$2->set_rtype($1->get_Name());



				// current=symboltable.Look_up($2->get_Name());
				// 		if(current==nullptr)
				// 		{
				// 				SymbolInfo *s=new SymbolInfo($2->get_Name(),"ID");
				// 				s->set_isfunction(true);
				// 				s->set_isDefi(true);
				// 				s->set_rtype($1->get_Type());
				// 				//symboltable.Insert_helper(s);
								
				// 				if(!symboltable.Insert_helper(s,logout))
				// 			{
				// 				cout<<"Error at insertion!"<<endl;
				// 			}
								


				// 		}

			} compound_statement{//cout<<"r12"<<endl;
					$$=new SymbolInfo("func_definition","type_specifier ID LPAREN RPAREN compound_statement");
						$3->set_start_line(line_count);
						$3->set_end_line(line_count);
						$4->set_start_line(line_count);
						$4->set_end_line(line_count);
						$$->addChildren($1);
						$$->addChildren($2);
						$$->addChildren($3);
						$$->addChildren($4);
						$$->addChildren($6);
						$$->set_start_line($1->get_start_line());


						$$->set_end_line($6->get_end_line());



				//symboltable.Print_All_Scope_tables(logout);
				symboltable.Exit_scope(logout,3);
			}
			/* {
				$$=new vector<SymbolInfo*>();
				$$->push_back($1);
						$$->push_back($2);
						$$->push_back($3);
						$$->push_back($4);
						for(int i=0;i<$6->size();i++)
						{
							$$->push_back($6->at(i));

						}
			} */
 		;				


parameter_list  : parameter_list COMMA type_specifier ID
					{//cout<<"r13"<<endl;
						print_to_log2("parameter_list", "parameter_list COMMA type_specifier ID");
						// $$=new vector<SymbolInfo*>();
						// for(int i=0;i<$1->size();i++)
						// {
						// 	$$->push_back($1->at(i));
						// }
						// $$->push_back($2);
						// $$->push_back($3);
						// $$->push_back($4);

						$$=new SymbolInfo("parameter_list", "parameter_list COMMA type_specifier ID");
						SymbolInfo *t=new SymbolInfo($4->get_Name(), $3->get_Name());
						$$->addChildren($1);
						$$->addChildren($2);
						$$->addChildren($3);
						$$->addChildren($4);
						$$->set_start_line($1->get_start_line());


						$$->set_end_line($4->get_end_line());
						params.push_back(t);


					}
		| parameter_list COMMA type_specifier
		{//cout<<"r14"<<endl;
		print_to_log2("parameter_list", "parameter_list COMMA type_specifier");
		// $$=new vector<SymbolInfo*>();
		// 				for(int i=0;i<$1->size();i++)
		// 				{
		// 					$$->push_back($1->at(i));
		// 				}
		// 				$$->push_back($2);
		// 				$$->push_back($3);
		// 				;
			$$=new SymbolInfo("parameter_list", "parameter_list COMMA type_specifier");
						SymbolInfo *t=new SymbolInfo("", $3->get_Name());
						$$->addChildren($1);
						$$->addChildren($2);
						$$->addChildren($3);
						$$->set_start_line($1->get_start_line());


						$$->set_end_line($3->get_end_line());
						
						params.push_back(t);	

		}
 		| type_specifier ID
		{//cout<<"r15"<<endl;
			print_to_log2("parameter_list", " type_specifier ID");
			$$=new SymbolInfo("parameter_list", "type_specifier ID");
						SymbolInfo *t=new SymbolInfo($2->get_Name(), $1->get_Name());
						$$->addChildren($1);
						$$->addChildren($2);
						$$->set_start_line($1->get_start_line());


						$$->set_end_line($2->get_end_line());
						
						params.push_back(t);	

						
		}
		| type_specifier
		{//cout<<"r16"<<endl;
			print_to_log2("parameter_list", "type_specifier");
			$$=new SymbolInfo("parameter_list", "type_specifier");
						SymbolInfo *t=new SymbolInfo("", $1->get_Name());
						$$->addChildren($1);
						$$->set_start_line($1->get_start_line());


						$$->set_end_line($1->get_end_line());
						
						params.push_back(t);	

		}
 		;

 		
compound_statement : LCURL
					{//cout<<"r17"<<endl;
						//cout << "even before log" << endl;
						//print_to_log2("compound_statement", " LCURL statements RCURLr");
						//cout << "before enter scope" << endl;
						
						symboltable.Enter_scope(11, logout);
						//cout << "after enter scope" << endl;
						//cout << children << endl;
						
						int parameter_count=params.size();
						for(int i=0;i<parameter_count;i++)
						{
							SymbolInfo *temp=params.at(i);
							//SymbolInfo* temp2=symboltable.Look_up($2->get_Name());
							//temp2->addParameters(temp->get_Name());
							symboltable.Insert(temp->get_Name(), "ID");

						}
							
							//cout << "outside condition" << endl;
						
						//cout << "after loop" << endl;

						
					} statements RCURL{	//cout<<"r18"<<endl;
						print_to_log2("compound_statement", " LCURL statements RCURL");
						cout<<"compound_statement <"<<$1->get_start_line()<<"  "<<$4->get_end_line()<<endl;
						$$=new SymbolInfo("compound_statement", " LCURL statements RCURL");
						$$->addChildren($1);
						$$->addChildren($3);
						$$->addChildren($4);
						$$->set_start_line($1->get_start_line());


						$$->set_end_line($4->get_end_line());
						symboltable.Print_All_Scope_tables(logout);
						symboltable.Exit_scope(logout,3);

					}
 		    | LCURL 
			{//cout<<"r19"<<endl;
				print_to_log2("compound_statement", " LCURL RCURLr");
				
						symboltable.Enter_scope(11, logout);
			}RCURL{//cout<<"r20"<<endl;
						$$=new SymbolInfo("compound_statement", " LCURL RCURL");
						$$->addChildren($1);
						$$->addChildren($3);
						$1->set_start_line(line_count);
						$1->set_end_line(line_count);
						$3->set_start_line(line_count);
						$3->set_end_line(line_count);
						
						$$->set_start_line($1->get_start_line());


						$$->set_end_line($3->get_end_line());

						
						symboltable.Print_All_Scope_tables(logout);
						symboltable.Exit_scope(logout,3);
			}
 		    ;
 		    
var_declaration : type_specifier declaration_list SEMICOLON
					{//cout<<"r21"<<endl;
						print_to_log2("var_declaration", "type_specifier declaration_list SEMICOLON");
						$$=new SymbolInfo("var_declaration", "type_specifier declaration_list SEMICOLON");
						$$->addChildren($1);
						$$->addChildren($2);

						$$->addChildren($3);
						
						
						$$->set_start_line($1->get_start_line());


						$$->set_end_line($3->get_end_line());
					}
 		 ;
 		 
type_specifier	: INT 
					{//cout<<"r22"<<endl;
							print_to_log2("type_specifier", "INT");
							//print_to_log1("INT",$1->get_Name());
							cout<<"type\n";
							$$=new SymbolInfo("type_specifier", "INT");
							$1=new SymbolInfo("INT", "int");
							$1->set_start_line(line_count);
							$1->set_end_line(line_count);
							$$->addChildren($1);
							$$->set_start_line(line_count);
							$$->set_end_line(line_count);
							str_for_data_type="int";



					}

 		| FLOAT
		{//cout<<"r23"<<endl;
			print_to_log2("type_specifier", "FLOAT");
			//print_to_log1($1->get_Type(), $1->get_Name());
			//$$=$1;
			$$=new SymbolInfo("type_specifier", "FLOAT");
							$1=new SymbolInfo("FLOAT", "float");
							$1->set_start_line(line_count);
							$1->set_end_line(line_count);
							$$->addChildren($1);
							$$->set_start_line(line_count);
							$$->set_end_line(line_count);
							str_for_data_type= "float";
		}
 		| VOID
		{//cout<<"r24"<<endl;
			print_to_log2("type_specifier", "VOID");
			//print_to_log1($1->get_Type(), $1->get_Name());
			$$=new SymbolInfo("type_specifier", "VOID");
							$1=new SymbolInfo("VOID", "void");
							$1->set_start_line(line_count);
							$1->set_end_line(line_count);
							$$->addChildren($1);
							$$->set_start_line(line_count);
							$$->set_end_line(line_count);
							str_for_data_type="void";
			cout<<$1->get_Name()<<"   naeme\tine\t"<<$1->get_start_line()<<"\n";
		}
 		;
 		
declaration_list : declaration_list COMMA ID
					{//cout<<"r25"<<endl;
						print_to_log2("declaration_list", "declaration_list COMMA ID");
						$3->set_rtype(str_for_data_type.c_str());
						if(!symboltable.Insert($3->get_Name(), $3->get_Type()));
						{
								cout<<"\n error at declaration_list : declaration_list COMMA ID\n";
						}
						$$=new SymbolInfo("declaration_list", "declaration_list COMMA ID");
						$$->addChildren($1);
						$2->set_start_line(line_count);
						$2->set_end_line(line_count);
						$$->addChildren($2);


						$$->addChildren($3);
						
						
						$$->set_start_line($1->get_start_line());


						$$->set_end_line($3->get_end_line());


					}

 		  | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD
		  {//cout<<"r26"<<endl;
			print_to_log2("declaration_list", "declaration_list COMMA ID LTHIRD CONST_INT RTHIRD");
			$3->set_rtype(str_for_data_type.c_str());
						if(!symboltable.Insert($3->get_Name(), $3->get_Type()));
						{
								cout<<"\n error at declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD\n";
						}
						$$=new SymbolInfo("declaration_list", "declaration_list COMMA ID LTHIRD CONST_INT RTHIRD");
						$$->addChildren($1);
						$2->set_start_line(line_count);
						$2->set_end_line(line_count);
						$$->addChildren($2);



						$$->addChildren($3);
						$4->set_start_line(line_count);
						$4->set_end_line(line_count);
						$$->addChildren($4);
						$$->addChildren($5);

						$6->set_start_line(line_count);
						$6->set_end_line(line_count);
						$$->addChildren($6);
						
						
						$$->set_start_line($1->get_start_line());


						$$->set_end_line($6->get_end_line());



		  }
 		  | ID
		  	{//cout<<"r27"<<endl;
				print_to_log2("declaration_list", "ID");
				//print_to_log1($1->get_Name(), $1->get_Type());
				$1->set_rtype(str_for_data_type.c_str());
						if(!symboltable.Insert($1->get_Name(), $1->get_Type()));
						{
								cout<<"\n error at declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD\n";
						}
						$$=new SymbolInfo("declaration_list", "ID");
						//$$-addChildren($1);
						$1->set_start_line(line_count);
						$1->set_end_line(line_count);
						$$->addChildren($1);
						$$->set_start_line(line_count);
						$$->set_end_line(line_count);
				cout<<"id" <<$1->get_start_line()<<$1->get_end_line()<<endl;

			}
 		  | ID LTHIRD CONST_INT RTHIRD
		  {//cout<<"r28"<<endl;
			print_to_log2("declaration_list", "ID LTHIRD CONST_INT RTHIRD");
			$1->set_rtype(str_for_data_type.c_str());
						if(!symboltable.Insert($1->get_Name(), $1->get_Type()));
						{
								cout<<"\n error at declaration_list :  ID LTHIRD CONST_INT RTHIRD\n";
						}
						$$=new SymbolInfo("declaration_list", "ID LTHIRD CONST_INT RTHIRD");
						
						$1->set_start_line(line_count);
						$1->set_end_line(line_count);
						$$->addChildren($1);



						
						$2->set_start_line(line_count);
						$2->set_end_line(line_count);
						$$->addChildren($2);
						$$->addChildren($3);

						$4->set_start_line(line_count);
						$4->set_end_line(line_count);
						$$->addChildren($4);
						
						
						$$->set_start_line($1->get_start_line());


						$$->set_end_line($4->get_end_line());
			//print_to_log1($1->get_Name(), $1->get_Type());
			
		  }
 		  ;
 		  
statements : statement
			{	//cout<<"r28"<<endl;
				print_to_log2("statements","statement");
				$$=new SymbolInfo("statements","statement");
				$1->set_end_line(line_count);
				$1->set_end_line(line_count);
				$$->set_start_line(line_count);
				$$->set_end_line(line_count);
				$$->addChildren($1);

				
			}
	   | statements statement
	   {	//cout<<"r29"<<endl;
			print_to_log2("statements","statements statement");
			$$=new SymbolInfo("statements","statements statement");
				$1->set_end_line(line_count);
				$1->set_end_line(line_count);
				$2->set_start_line(line_count);
				$2->set_end_line(line_count);
				$$->addChildren($1);
				$$->addChildren($2);
						
						
						$$->set_start_line($1->get_start_line());


						$$->set_end_line($2->get_end_line());

			
	   }
	   ;
	   
statement : var_declaration
			{	//cout<<"r30"<<endl;
				print_to_log2("statement","var_declaration");
				$$=new SymbolInfo("statements","var_declaration");
				$1->set_end_line(line_count);
				$1->set_end_line(line_count);
				$$->set_start_line(line_count);
				$$->set_end_line(line_count);
				$$->addChildren($1);

				
			}
	  | expression_statement
	  {	//cout<<"r31"<<endl;
		print_to_log2("statement","expression_statement");
		$$=new SymbolInfo("statements","expression_statement");
				$1->set_end_line(line_count);
				$1->set_end_line(line_count);
				$$->set_start_line(line_count);
				$$->set_end_line(line_count);
				$$->addChildren($1);

	  }
	  | compound_statement
	  {	//cout<<"r32"<<endl;
		symboltable.Enter_scope(11,logout);
		$$=new SymbolInfo("statements","compound_statement");
				$1->set_end_line(line_count);
				$1->set_end_line(line_count);
				$$->set_start_line(line_count);
				$$->set_end_line(line_count);
				$$->addChildren($1);


	  }
	  | FOR LPAREN expression_statement expression_statement expression RPAREN statement
	  {	//cout<<"r33"<<endl;
		print_to_log2("statement","FOR LPAREN expression_statement expression_statement expression RPAREN statement");

		$$=new SymbolInfo("statements","FOR LPAREN expression_statement expression_statement expression RPAREN statement");
		$$->addChildren($1);
				$2->set_end_line(line_count);
				$2->set_end_line(line_count);
				$$->addChildren($2);
				$$->addChildren($3);
				$$->addChildren($4);
				$$->addChildren($5);
				$6->set_end_line(line_count);
				$6->set_end_line(line_count);
				$$->addChildren($6);
				$$->addChildren($7);
				$$->set_start_line($1->get_start_line());
				$$->set_end_line($7->get_end_line());
				





		

	  }
	  | IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE
	  {	//cout<<"r34"<<endl;
		print_to_log2("statement","IF LPAREN expression RPAREN statement");
		$$=new SymbolInfo("statements","IF LPAREN expression_statement RPAREN statement");
		$$->addChildren($1);
				$2->set_end_line(line_count);
				$2->set_end_line(line_count);
				$$->addChildren($2);
				$$->addChildren($3);
				
				$4->set_end_line(line_count);
				$4->set_end_line(line_count);
				$$->addChildren($4);
				$$->addChildren($5);
				$$->set_start_line($1->get_start_line());
				$$->set_end_line($5->get_end_line());

	  }
	  | IF LPAREN expression RPAREN statement ELSE statement
	  {	//cout<<"r35"<<endl;
		print_to_log2("statement","IF LPAREN expression RPAREN statement ELSE statement");
			$$=new SymbolInfo("statements","IF LPAREN expression RPAREN statement ELSE statement");
		$$->addChildren($1);
				$2->set_end_line(line_count);
				$2->set_end_line(line_count);
				$$->addChildren($2);
				$$->addChildren($3);
				
				$4->set_end_line(line_count);
				$4->set_end_line(line_count);
				$$->addChildren($4);
				$$->addChildren($5);
				$$->addChildren($6);
				$$->addChildren($7);
				$$->set_start_line($1->get_start_line());
				$$->set_end_line($7->get_end_line());


	  }
	  | WHILE LPAREN expression RPAREN statement
	  {	//cout<<"r36"<<endl;
		print_to_log2("statement","WHILE LPAREN expression RPAREN statement");
		$$=new SymbolInfo("statements","WHILE LPAREN expression RPAREN statement");
		$$->addChildren($1);
				$2->set_end_line(line_count);
				$2->set_end_line(line_count);
				$$->addChildren($2);
				$$->addChildren($3);
				
				$4->set_end_line(line_count);
				$4->set_end_line(line_count);
				$$->addChildren($4);
				$$->addChildren($5);
				$$->set_start_line($1->get_start_line());
				$$->set_end_line($5->get_end_line());


	  }
	  | PRINTLN LPAREN ID RPAREN SEMICOLON
	  {	//cout<<"r37"<<endl;
		print_to_log2("statement","PRINTLN LPAREN ID RPAREN SEMICOLON");
		$$=new SymbolInfo("statements","PRINTLN LPAREN ID RPAREN SEMICOLON");
		 $1=new SymbolInfo("PRINTLN","println");
		$1->set_end_line(line_count);
				$1->set_end_line(line_count);
		$$->addChildren($1);
				$2->set_end_line(line_count);
				$2->set_end_line(line_count);
				$$->addChildren($2);
				$3->set_end_line(line_count);
				$3->set_end_line(line_count);
				$$->addChildren($3);
				
				$4->set_end_line(line_count);
				$4->set_end_line(line_count);
				$$->addChildren($4);
				$5->set_end_line(line_count);
				$5->set_end_line(line_count);
				$$->addChildren($5);
				$$->set_start_line($1->get_start_line());
				$$->set_end_line($5->get_end_line());
		

	  }
	  | RETURN expression SEMICOLON
	  {//cout<<"r38"<<endl;
		print_to_log2("statement","RETURN expression SEMICOLON");
		$$=new SymbolInfo("statements","RETURN expression SEMICOLON");
		$1=new SymbolInfo("RETURN", "RETURN expression SEMICOLON");
		$$->addChildren($1);
				$1->set_end_line(line_count);
				$1->set_end_line(line_count);
				$$->addChildren($2);
				
				$3->set_end_line(line_count);
				$3->set_end_line(line_count);
				$$->addChildren($3);
				
				$$->set_start_line($1->get_start_line());
				$$->set_end_line($3->get_end_line());
		
	  }
	  ;
	  
expression_statement 	: SEMICOLON	
						{	//cout<<"r39"<<endl;
							print_to_log2("expression_statement", "SEMICOLON");
							$$=new SymbolInfo("expression_statement", "SEMICOLON");
					$1->set_end_line(line_count);
					$1->set_end_line(line_count);
					$$->set_start_line(line_count);
					$$->set_end_line(line_count);
					$$->addChildren($1);
							
							cout<<"semicolon";
						}
		
			| expression SEMICOLON 
			{		//cout<<"r40"<<endl;
				print_to_log2("expression_statement", "expression SEMICOLON");
				$$=new SymbolInfo("expression_statement", "SEMICOLON");
				$$->addChildren($1);
				$2->set_end_line(line_count);
				$2->set_end_line(line_count);
				$$->addChildren($2);
				$$->set_start_line($1->get_start_line());
				$$->set_end_line($2->get_end_line());
				
							
				
			}
			;
	  
variable : ID 	
			{//cout<<"r41"<<endl;
				print_to_log2("variable", "ID");
				$$=new SymbolInfo("variable", "ID");
				$1->set_start_line(line_count);
				$1->set_end_line(line_count);
				$$->addChildren($1);
				$$->set_start_line($1->get_start_line());
				$$->set_end_line($1->get_end_line());

			}	
	 | ID LTHIRD expression RTHIRD 
	 {cout<<"r42"<<endl;
		print_to_log2("variable", "ID LTHIRD expression RTHIRD");
		$$=new SymbolInfo("variable", "ID LTHIRD expression RTHIRD");
				$1->set_start_line(line_count);
				$1->set_end_line(line_count);
				$$->addChildren($1);
				$2->set_start_line(line_count);
				$2->set_end_line(line_count);
				$$->addChildren($2);
				
				$$->addChildren($3);
				$4->set_start_line(line_count);
				$4->set_end_line(line_count);
				$$->addChildren($4);
				$$->set_start_line($1->get_start_line());
				$$->set_end_line($4->get_end_line());


	 }
	 ;
	 
 expression : logic_expression	
				{cout<<"r43"<<endl;
					print_to_log2("expression", "logic_expression");
					cout<<"here1";
					$$=new SymbolInfo("expression", "logic_expression");
				$1->set_start_line(line_count);
				$1->set_end_line(line_count);
				$$->addChildren($1);
				$$->set_start_line($1->get_start_line());
				$$->set_end_line($1->get_end_line());
					

				}
	   | variable ASSIGNOP logic_expression 
	   {cout<<"r44"<<endl;
		print_to_log2("expression", "variable ASSIGNOP logic_expression");
		string variable_name="";
		// if ($1->get_Type() == "ARRAY_VAR") {
		// 			int pos = $1->get_Name().find('[');
		// 			variable_name = $1->get_Name().substr(0,pos);
		// 		} else if($1->get_Type() == "ID") {
		// 			variableName = $1->get_name();
		// 		}
		// 		str_for_data_type= "";


				$$=new SymbolInfo("expression", "variable ASSIGNOP logic_expression");
				
				$$->addChildren($1);
				$2->set_start_line(line_count);
				$2->set_end_line(line_count);
				$$->addChildren($2);
				
				$$->addChildren($3);
				
				$$->set_start_line($1->get_start_line());
				$$->set_end_line($3->get_end_line());

	   }	
	   ;
			
logic_expression : rel_expression 	
					{cout<<"r45"<<endl;
						print_to_log2("logic_expression", "rel_expression");
					$$=new SymbolInfo("logic_expression", "rel_expression");
				$1->set_start_line(line_count);
				$1->set_end_line(line_count);
				$$->addChildren($1);
				$$->set_start_line($1->get_start_line());
				$$->set_end_line($1->get_end_line());

					}
		 | rel_expression LOGICOP rel_expression 	
		 {cout<<"r46"<<endl;
			print_to_log2("logic_expression", "rel_expression LOGICOP rel_expression");
			$$=new SymbolInfo("logic_expression", "rel_expression LOGICOP rel_expression");
				
				$$->addChildren($1);
				$2->set_start_line(line_count);
				$2->set_end_line(line_count);
				$$->addChildren($2);
				
				$$->addChildren($3);
				
				$$->set_start_line($1->get_start_line());
				$$->set_end_line($3->get_end_line());
			
		 }
		 ;
			
rel_expression	: simple_expression 
				{cout<<"r47"<<endl;
					print_to_log2("rel_expression", "simple_expression");
					$$=new SymbolInfo("rel_expression", "simple_expression");
				$1->set_start_line(line_count);
				$1->set_end_line(line_count);
				$$->addChildren($1);
				$$->set_start_line($1->get_start_line());
				$$->set_end_line($1->get_end_line());

				}
		| simple_expression RELOP simple_expression	
		{cout<<"r48"<<endl;
			print_to_log2("rel_expression", "simple_expression RELOP simple_expression");
			$$=new SymbolInfo("rel_expression", "simple_expression RELOP simple_expression");
				
				$$->addChildren($1);
				$2->set_start_line(line_count);
				$2->set_end_line(line_count);
				$$->addChildren($2);
				
				$$->addChildren($3);
				
				$$->set_start_line($1->get_start_line());
				$$->set_end_line($3->get_end_line());
			
		}
		;
				
simple_expression : term 
					{cout<<"r49"<<endl;
						print_to_log2("simple_expression", "term");
					$$=new SymbolInfo("simple_expression", "term");
				$1->set_start_line(line_count);
				$1->set_end_line(line_count);
				$$->addChildren($1);
				$$->set_start_line($1->get_start_line());
				$$->set_end_line($1->get_end_line());
					
					}
		  | simple_expression ADDOP term 
		  {cout<<"r50"<<endl;
			print_to_log2("simple_expression", "simple_expression ADDOP term");
			$$=new SymbolInfo("simple_expression", "simple_expression ADDOP term");
				
				$$->addChildren($1);
				$2->set_start_line(line_count);
				$2->set_end_line(line_count);
				$$->addChildren($2);
				
				$$->addChildren($3);
				
				$$->set_start_line($1->get_start_line());
				$$->set_end_line($3->get_end_line());


		  }
		  ;
					
term :	unary_expression
		{cout<<"r51"<<endl;
			print_to_log2("term", "unary_expression");
			$$=new SymbolInfo("term", "unary_expression");
				$1->set_start_line(line_count);
				$1->set_end_line(line_count);
				$$->addChildren($1);
				$$->set_start_line($1->get_start_line());
				$$->set_end_line($1->get_end_line());

		}
     |  term MULOP unary_expression
	 
	 {cout<<"r52"<<endl;
		print_to_log2("term", "term MULOP unary_expression");
		$$=new SymbolInfo("term", "term MULOP unary_expression");
				
				$$->addChildren($1);
				$2->set_start_line(line_count);
				$2->set_end_line(line_count);
				$$->addChildren($2);
				
				$$->addChildren($3);
				
				$$->set_start_line($1->get_start_line());
				$$->set_end_line($3->get_end_line());
		
	 }
     ;

unary_expression : ADDOP unary_expression  
				{cout<<"r53"<<endl;
					print_to_log2("unary_expression", "ADDOP unary_expression");
					$$=new SymbolInfo("unary_expression", "ADDOP unary_expression");
					
				
				
				$1->set_start_line(line_count);
				$1->set_end_line(line_count);
				$$->addChildren($1);
				
				$$->addChildren($1);
				
				$$->set_start_line($1->get_start_line());
				$$->set_end_line($2->get_end_line());
				}
		 | NOT unary_expression 
		 {cout<<"r54"<<endl;
			print_to_log2("unary_expression", "NOT unary_expression");
			$$=new SymbolInfo("unary_expression", "NOT unary_expression");
					
				
				
				$1->set_start_line(line_count);
				$1->set_end_line(line_count);
				$$->addChildren($1);
				
				$$->addChildren($1);
				
				$$->set_start_line($1->get_start_line());
				$$->set_end_line($2->get_end_line());
		 }
		 | factor 
		 {cout<<"r55"<<endl;
			print_to_log2("unary_expression", "factor");
			$$=new SymbolInfo("unary_expression", "factor");
				$1->set_start_line(line_count);
				$1->set_end_line(line_count);
				$$->addChildren($1);
				$$->set_start_line($1->get_start_line());
				$$->set_end_line($1->get_end_line());

		 }
		 ;
	
factor	: variable 
		{cout<<"r56"<<endl;
			print_to_log2("factor", "variable");
			$$=new SymbolInfo("factor", "variable");
				$1->set_start_line(line_count);
				$1->set_end_line(line_count);
				$$->addChildren($1);
				$$->set_start_line($1->get_start_line());
				$$->set_end_line($1->get_end_line());
		}
	| ID LPAREN argument_list RPAREN
	{cout<<"r57"<<endl;
		print_to_log2("factor", "ID LPAREN argument_list RPAREN");
		
		
		//children_Arg->clear();

		$$=new SymbolInfo("factor", "ID LPAREN argument_list RPAREN");

		$1->set_start_line(line_count);
				$1->set_end_line(line_count);
				$$->addChildren($1);
				
				
				$2->set_start_line(line_count);
				$2->set_end_line(line_count);
				
				
				$$->addChildren($2);
				$$->addChildren($3);

				$4->set_start_line(line_count);
				$4->set_end_line(line_count);
				
				
				$$->addChildren($4);
				
				$$->set_start_line($1->get_start_line());
				$$->set_end_line($4->get_end_line());



	}
	| LPAREN expression RPAREN
	{//cout<<"r58"<<endl;
		print_to_log2("factor", "LPAREN expression RPAREN");
		$$=new SymbolInfo("factor", "ID LPAREN argument_list RPAREN");

		$1->set_start_line(line_count);
				$1->set_end_line(line_count);
				$$->addChildren($1);
				
				
				$3->set_start_line(line_count);
				$3->set_end_line(line_count);
				
				
				$$->addChildren($2);
				$$->addChildren($3);

				
				$$->set_start_line($1->get_start_line());
				$$->set_end_line($3->get_end_line());
		

	}
	| CONST_INT 
	{//cout<<"r59"<<endl;
		print_to_log2("factor", "CONST_INT");
		$$=new SymbolInfo("factor", "CONST_INT");
				$1->set_start_line(line_count);
				$1->set_end_line(line_count);
				$$->addChildren($1);
				$$->set_start_line($1->get_start_line());
				$$->set_end_line($1->get_end_line());
		
	}
	| CONST_FLOAT
	{//cout<<"r60"<<endl;
		print_to_log2("factor", "CONST_FLOAT");
		$$=new SymbolInfo("factor", "CONST_FLOAT");
				$1->set_start_line(line_count);
				$1->set_end_line(line_count);
				$$->addChildren($1);
				$$->set_start_line($1->get_start_line());
				$$->set_end_line($1->get_end_line());
	}
	| variable INCOP 
	{	//cout<<"r61"<<endl;
		print_to_log2("factor", "variable INCOP");
		$$=new SymbolInfo("factor", "variable INCOP");
		$$->addChildren($1);
				$2->set_start_line(line_count);
				$2->set_end_line(line_count);
				$$->addChildren($2);
				$$->set_start_line($1->get_start_line());
				$$->set_end_line($2->get_end_line());
	
	}
	| variable DECOP
	{//cout<<"r62"<<endl;
		print_to_log2("factor", "variable DECOP");
		$$=new SymbolInfo("factor", "variable DECOP");
		$$->addChildren($1);
				$2->set_start_line(line_count);
				$2->set_end_line(line_count);
				$$->addChildren($2);
				$$->set_start_line($1->get_start_line());
				$$->set_end_line($2->get_end_line());
	}
	;
	
argument_list : arguments
				{//cout<<"r63"<<endl;
					print_to_log2("argument_list", "arguments");
					$$=new SymbolInfo("argument_list", "arguments");
				$1->set_start_line(line_count);
				$1->set_end_line(line_count);
				$$->addChildren($1);
				$$->set_start_line($1->get_start_line());
				$$->set_end_line($1->get_end_line());
				}
				| {cout<<"r64"<<endl;
				$$ = new SymbolInfo("", "BLANK_ARGUMENT_LIST"); 
			}
			  
			  ;
	
arguments : arguments COMMA logic_expression
			{//cout<<"r65"<<endl;
				print_to_log2("arguments","arguments COMMA logic_expression");
				$$=new SymbolInfo("arguments","arguments COMMA logic_expression");
		$$->addChildren($1);
				$2->set_start_line(line_count);
				$2->set_end_line(line_count);
				$$->addChildren($2);
				SymbolInfo *sym=new SymbolInfo($3->get_Name(), $3->get_Type());
				//children_Arg->push_back(sym);
				$$->addChildren($3);
				$$->set_start_line($1->get_start_line());
				$$->set_end_line($3->get_end_line());
				

			}
	      | logic_expression
		  {//cout<<"r66"<<endl;
			
			print_to_log2("arguments","logic_expression");
			$$=new SymbolInfo("arguments","logic_expression");
				$1->set_start_line(line_count);
				$1->set_end_line(line_count);
				
				SymbolInfo *sym=new SymbolInfo($1->get_Name(), $1->get_Type());
				
				//children_Arg->push_back(sym);
				
				$$->addChildren($1);
				$$->set_start_line($1->get_start_line());
				$$->set_end_line($1->get_end_line());
		  }

	      ;
 

%%
int main(int argc,char *argv[])
{

	
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
	parseout.open("2005083_parse_tree.txt");
	errorout.open("2005083_error.txt");
	assembly_out.open("2005083_assembly.asm");

	yyparse();

	fclose(yyin);
	//symboltable.Enter_scope(11,logout);
	//symboltable.Print_All_Scope_tables(logout);
	logout<<"Total Lines: "<<line_count-1<<endl;
	parseout<<"Total Lines: "<<line_count-1<<endl;

	//fclose(fp2);
	//fclose(fp3);
	logout.close();
	parseout.close();
	errorout.close();
	assembly_out.close();
	
	return 0;
}


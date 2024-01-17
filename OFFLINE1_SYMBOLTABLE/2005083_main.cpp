#include<iostream>
#include<fstream>
#include "2005083.cpp"
using namespace std;

int main()
{
    int bucket_no;
    ifstream infile;
    ofstream outfile;
    int table_counte=0;
    infile.open("input.txt");
    outfile.open("out.txt");
    infile>>bucket_no;
    //cout<<bucket_no;
    SymbolTable symbolTable;
    symbolTable.Enter_scope(bucket_no, outfile);
    table_counte++;
    //outfile<<"\tScopeTable# 1 created\n";
    string line;
    bool check;
    int command_counter=1;
    getline(infile, line);
    while(getline(infile, line))
    {
        istringstream iss(line);
        char c;
        string arg1, arg2;
        string arg3;
        // cout<<c<<'\t'<<arg1<<'\t'<<arg2<<'\n';

        if (!(iss >> c >> arg1 >> arg2))
        {
            outfile<<"Cmd "<<command_counter<<": "<<c;
            if(arg1=="")
            {
                outfile<<'\n';
            }
            else
            {
                outfile<<" "<<arg1<<'\n';
            }


            command_counter++;
            // cout<<arg3<<"here";

            switch (c)
            {

            case 'L':
            {
                SymbolInfo* sym1=symbolTable.Look_up(arg1.c_str(),outfile);
                //cout<<sym1->get_Name()<<" lokk";
                //cout<<sym1->get_Type();
                if(sym1==nullptr) outfile<< "\t'"<<arg1<<"' not found in any of the ScopeTables"<<'\n';


                break;
            }
            case 'D':
                if(arg1=="")
                    //cout<<arg1<<" in delete";
                {
                    outfile<<"\tWrong number of arugments for the command "<<c<<'\n';
                    break;
                }
                else
                {
                    check= symbolTable.Remove(arg1.c_str(), outfile);
                    //if(!check) outfile<< "Not found in the current ScopeTable# "<<symbolTable.get_scope_id()<<'\n';
                    break;
                }
            case 'P':

                //cout<<"\nok!";
                if (arg1 == "A")
                {
                    symbolTable.Print_All_Scope_tables(outfile);
                }
                else if (arg1 == "C")
                {
                    symbolTable.Print_Current_Scope_table(outfile);
                }
                else
                {
                    outfile<< "\tInvalid argument for the command P"  << endl;
                }
                break;

            case 'S':
                //cout<<arg1<<"ins";
                // cout<<stoi(arg1);
                table_counte++;
                symbolTable.Enter_scope(bucket_no, outfile);
                break;
            case 'E':
            {
                int k=strlen(symbolTable.get_scope_id());

                char *id=new char[k+1];
                //cout<<symbolTable.get_scope_id()<<'\n';
                strcpy(id, symbolTable.get_scope_id());
                //id=symbolTable.get_scope_id();
                if(strcmp(id, "1")==0)
                {
                    outfile<<"\tScopeTable# "<<symbolTable.get_scope_id()<<" cannot be deleted\n";
                    break;
                }
                table_counte--;
                //cout<<"\ntable     "<<table_counte;
                symbolTable.Exit_scope(outfile,8);
                break;
            }
            case 'Q':
            {
                int k=strlen(symbolTable.get_scope_id());

                char *id=new char[k+1];
                //cout<<symbolTable.get_scope_id()<<'\n';
                strcpy(id, symbolTable.get_scope_id());
                //cout<<"inn     "<<table_counte;
                while(table_counte!=1)
                {
                    symbolTable.Exit_scope(outfile,8);
                    table_counte--;
                   // cout<<"i    "<<table_counte;
                }

                if(strcmp(id, "1")==0)
                {
                   // cout<<"\tScopeTable# "<<symbolTable.get_scope_id()<<" cannot be deleted\n";


                }

                //id=symbolTable.get_scope_id();
                if(table_counte==1)
                {
                    //cout<<"kkk"<<symbolTable.get_scope_id()<<'\n';
                    symbolTable.Exit_scope(outfile,0);

                }
                break;
            }
            default:
                if(c!=' ')
                {
                    outfile << "\tWrong number of arugments for the command " << c << endl;
                }
                break;
            }




            continue;

        }
        //  cout<<arg3<<"here3";
        outfile<<"Cmd "<<command_counter<<": "<<c<<" "<<arg1<<" "<<arg2<<'\n';
        command_counter++;
        switch (c)
        {
        case 'I':
            //cout<<arg1.c_str();
            //cout<<arg2.c_str();
            check=symbolTable.Insert(arg1.c_str(), arg2.c_str(),outfile);
           // if(!check) cout<< " eroor done!";
            //cout<<endl;
            break;



        default:
            outfile << "\tWrong number of arugments for the command " << c << endl;
        }
    }
    // symbolTable.Print_All_Scope_tables();


    infile.close();
    outfile.close();
    return 0;

}



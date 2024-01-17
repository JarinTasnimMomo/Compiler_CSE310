#include <iostream>
#include <cstring>
#include <fstream>
#include <sstream>
using namespace std;
class SymbolInfo
{
private:
    char* Name;
    char* Type;
    SymbolInfo* Next;
public:
    SymbolInfo(const char* name, const char* type )
    {
        Name=nullptr;
        Type=nullptr;        //not pointing to any valid memory location until I explicitly allocate memory for them.
        Next=nullptr;
        if(name!=nullptr)
        {
            Name=new char[strlen(name)+1];
            strcpy(Name, name);

        }
        if(type!=nullptr)
        {
            Type=new char[strlen(type)+1];
            strcpy(Type, type);

        }
    }
    ~SymbolInfo()
    {
        delete[] Name;
        delete[] Type;
    }
    const char* get_Name ()const
    {
        return Name;
    }
    const char* get_Type ()const
    {
        return Type;
    }
    SymbolInfo* get_Next ()const
    {
        return Next;
    }
    void set_Next(SymbolInfo* new_next)
    {
        Next=new_next;
    }

};

class ScopeTable
{
private:
    unsigned long long Bucket_size;
    SymbolInfo **Bucket;
    ScopeTable* parent;
    char* Scope_id;
    unsigned long long scope_id_counter;

    size_t Hash(const char* str) const
    {
        size_t hash_v=0;
        int c;
        while((c=*str++))
        {
            hash_v= c + (hash_v << 6) + (hash_v << 16) - hash_v;

        }
        return hash_v%Bucket_size;

    }
public:
    int parent_scope_counter;
    ScopeTable( ScopeTable* p, unsigned long long b)
    {
        parent=p;
        Bucket_size=b;
        Bucket= new SymbolInfo* [Bucket_size]();
        Scope_id=nullptr;
        scope_id_counter=0;
        parent_scope_counter=1;
        // cout<<"ok!";
        if(p)
        {
            size_t p_scope_idlen= strlen(p->Scope_id);
            size_t p_id=p->get_scope_id_counter();


            size_t counter= snprintf(nullptr, 0, "%lu",p_id);
            //cout<<"p_id  "<<counter;
            //size_t counter= snprintf(nullptr, 0, "%d",parent_scope_counter);
            Scope_id=new char [p_scope_idlen+1+counter+1];
            scope_id_counter++;
            //cout<<;
            // cout<<p->Scope_id;
            snprintf(Scope_id, p_scope_idlen+1+counter+1, "%s.%lu", p->Scope_id, p_id );
            //cout<<Scope_id;
            //cout<<Scope_id;

        }
        else
        {
            Scope_id = strdup(to_string(++scope_id_counter).c_str());
        }
        /* if(Scope_id!=nullptr)
         {
             cout<<Scope_id;
         }
         else
         {
             cout<<"null";
         }*/

    }

    ~ScopeTable()
    {
        delete [] Scope_id;
        for(int i=0; i<Bucket_size; i++)
        {

            SymbolInfo* c=Bucket[i];
            while(c!=nullptr)
            {

                SymbolInfo* next=c->get_Next();
                delete c;
                c=next;

            }
        }
        delete [] Bucket;
    }
    bool Insert(SymbolInfo* sym, ofstream &out)
    {
        //cout<<"          inside";
        size_t index= Hash(sym->get_Name());
        //cout<< index;
        if(Bucket[index]==nullptr)
        {
            Bucket[index]=sym;
            //cout<<Bucket[index]->get_Name();
            //out<<" '"<< Bucket[index]->get_Name()<<" '";
            out<<"\tInserted  at position <"<<index+1<< ", "<<scope_id_counter<<"> of ScopeTable# "<< Scope_id<<endl;;
            return true;
        }
        else
        {
            SymbolInfo* curr= Bucket[index];
            int counter=1;

            if(curr->get_Next()==nullptr)
            {
                int cmp=strcmp(sym->get_Name(), curr->get_Name());
                if(cmp==0)
                {
                    out<<"\t'"<< Bucket[index]->get_Name()<<"'";
                    out<<" already exists in the current ScopeTable# "<<Scope_id<<endl;
                    return false;
                }
                else
                {
                    //cout<<"hlast   "<<sym->get_Name();
                    curr->set_Next(sym);
                    counter+=1;
                    out<<"\tInserted  at position <"<<index+1<< ", "<<counter<<"> of ScopeTable# "<< Scope_id<<endl;
                    return true;




                }
            }
            else
            {
                //int counter=1;

                while(curr->get_Next()!=nullptr)
                {
                    counter+=1;
                    //cout<<curr->get_Name()<<" and "<<sym->get_Name();
                    curr=curr->get_Next();

                    //cout<<"cmp  "<<strcmp(sym->get_Name(), curr->get_Name());
                    /* if(strcmp(curr->get_Name(),sym->get_Name())==0)
                     {
                         //cout<<"compare 0"<<curr->get_Name();
                         out<<"\t '"<< Bucket[index]->get_Name()<<"'";
                         out<<"already exists in the current ScopeTable# "<<scope_id_counter<<'\n';

                         return false;
                     }
                     else
                     {
                         if(curr->get_Next()==nullptr)
                         {   cout<<"last"<<sym->get_Name();
                             curr->set_Next(sym);
                             out<<"\tInserted  at position <"<<index+1<< ", "<<counter<<"> of ScopeTable# "<< Scope_id<<endl;
                             return true;
                         }

                     }*/


                }
                // cout<<"last"<<sym->get_Name();
                curr->set_Next(sym);
                counter+=1;
                out<<"\tInserted  at position <"<<index+1<< ", "<<counter<<"> of ScopeTable# "<< Scope_id<<endl;
                return true;



            }
            // cout<<"cmp2  "<<strcmp(sym->get_Name(), curr->get_Name());


            //


        }
    }
    bool Is_empty()
    {
        for(unsigned long long i=0; i<Bucket_size; i++)
        {
            if(Bucket[i]!=nullptr)
            {
                return false;
            }

        }
        return true;
    }
    SymbolInfo* Look_up(const char* name,  ofstream &out)const
    {
        /* if(Is_empty())
         {
             cout<<"TAble is empty..";
             return NULL;
         }*/
        //cout<<"here";
        int counter=0;
        size_t index= Hash(name);
        SymbolInfo* curr= Bucket[index];
        while(curr!=nullptr)
        {
            counter++;
            if(strcmp(curr->get_Name(),name)==0)
            {
                out<<"\t'"<< curr->get_Name()<<"' ";
                out<<"found at position <"<<index+1<< ", "<<counter<<"> of ScopeTable# "<< Scope_id<<'\n';

                return curr;
            }
            curr=curr->get_Next();
        }

        // cout<<" symbol not found!";

        return nullptr;
    }


    bool Remove(const char* name, ofstream &out)
    {
        if(Is_empty())
        {
            out<<"Table is empty.";
            return false;
        }
        size_t index= Hash(name);
        SymbolInfo* curr= Bucket[index];
        SymbolInfo* pre=nullptr;

        while(curr!=nullptr)
        {
            if(strcmp(curr->get_Name(),name)==0)
            {
                if(pre==nullptr)
                {
                    Bucket[index]=curr->get_Next();
                }
                else
                {
                    pre->set_Next(curr->get_Next());
                }
                out<<"\tDeleted '"<< curr->get_Name()<<"' ";
                out<<"from position <"<<index+1<< ", "<<scope_id_counter<<"> of ScopeTable# "<< Scope_id<<'\n';
                delete curr;
                return true;

            }
            pre=curr;
            curr=curr->get_Next();

            // curr=curr->get_Next();
        }
        out<< "\tNot found in the current ScopeTable# "<<Scope_id<<'\n';
        //cout<<" symbol not found to delete !";

        return false;

    }
    ScopeTable* get_parent_scope() const
    {
        return parent;
    }
    const char* get_scope_id()
    {
        return Scope_id;
    }


    void print (ofstream &out)
    {
        //cout<<"in print of scopetable";
        out<<"\tScopeTable# "<< Scope_id<< '\n';
        for(int i=0; i<Bucket_size; i++)
        {
            out <<'\t'<< i+1 ;
            //<< " --> ";
            SymbolInfo* curr = Bucket[i];
            while (curr != nullptr)
            {
                // if(curr != nullptr & curr->get_Next()==nullptr)
                out << "";
                out<< " --> (" << curr->get_Name() << "," << curr->get_Type() << ")";
                //if(curr->get_Next()!=nullptr) out<<" --> ";
                curr = curr->get_Next();

            }
            out << '\n';
        }
    }
    void set_scope_id_counter(int i)
    {
        scope_id_counter=i;
    }
    unsigned long long get_scope_id_counter()
    {
        return scope_id_counter;
    }

    /* void set_bucket_size( unsigned long long s)
     {
         Bucket_size=s;
     }*/


};

//int ScopeTable:: scope_id_counter=0;

class SymbolTable
{
private:
    ScopeTable* Scope;
public:
    SymbolTable()
    {
        Scope=nullptr;
    }
    ~ SymbolTable()
    {
        while(Scope!=nullptr)
        {
            ScopeTable* parent=Scope->get_parent_scope();
            delete Scope;
            Scope=parent;

        }
    }
    void Enter_scope( int bucket_size, ofstream &out)
    {
        ScopeTable* new_scope=new ScopeTable(Scope,bucket_size);
        Scope=new_scope;
        //int k= Scope->get_scope_id_counter();
        //cout<<"k "<<k;
        //Scope->set_scope_id_counter(k++);
        //cout<<"k     "<<k;
        out<<'\t'<<"ScopeTable# "<<Scope->get_scope_id()<<" created\n";

    }
    void Exit_scope(ofstream &out,int k)
    {
        if(Scope!=nullptr)
        {
            //cout<<"here   ";

            if(Scope->get_parent_scope()!=nullptr)
            {
                int i=Scope->get_parent_scope()->get_scope_id_counter()+1;
                //cout<<"i   "<<i;

                Scope->get_parent_scope()->set_scope_id_counter(i);
                // cout<<" i"<<Scope->get_parent_scope()->get_scope_id_counter();
                out<<"\tScopeTable# "<<Scope->get_scope_id()<<" deleted\n";
                ScopeTable* parent=Scope->get_parent_scope();

                //  cout<<"p"<<Scope->get_parent_scope()->parent_scope_counter<<'\t';
                //Scope->get_parent_scope->set_scope_id_counter()



                delete Scope;



                Scope=parent;
            }
            else
            {
                if(k==0)
                {
                    //cout<<"one";
                    out<<"\tScopeTable# "<<Scope->get_scope_id()<<" deleted\n";
                   // cout<<"\tScopeTable# "<<Scope->get_scope_id()<<" deleted\n";

                    Scope=nullptr;
                }
            }


        }

        //out<<"\tScopeTable# "<<Scope->get_scope_id()<<" deleted\n";
        //delete Scope;


    }
    bool Insert(const char* name, const char* type, ofstream &outfile)
    {

        if(Scope!=nullptr)
        {
            SymbolInfo* sym=new SymbolInfo(name, type);
            // return Scope->get_parent_scope();
            return Scope->Insert(sym, outfile);
        }
        return false;
    }
    bool Remove(const char* name, ofstream &outfile)
    {
        if(Scope!=nullptr)
        {
            //SymbolInfo* sym=new SymbolInfo(name, type);
            return Scope->Remove(name, outfile);
        }
        return false;
    }

    SymbolInfo* Look_up(const char* n, ofstream &outfile) const
    {
        ScopeTable *curr= Scope;
        while(curr!=nullptr)
        {
            SymbolInfo *sym=curr->Look_up(n, outfile);
            if(sym!=nullptr)
            {
                return sym;
            }
            curr=curr->get_parent_scope();

        }
        // cout<<" no symbol found";
        return nullptr;
    }

    const char* get_scope_id() const
    {
        if(Scope!=nullptr)
        {
            return Scope->get_scope_id();
        }
        return nullptr;
    }

    void Print_Current_Scope_table(ofstream &outfile) const
    {
        if(Scope!=nullptr)
        {
            //cout<<"in print of symboltable";
            Scope->print(outfile);

        }
        else
        {
            cout<<"No current Scope table to print"<<endl;
        }
    }
    void Print_All_Scope_tables(ofstream &outfile) const
    {
        ScopeTable * curr=Scope;
        while(curr!=nullptr)
        {
            curr->print(outfile);
            //cout<<'\n';
            curr=curr->get_parent_scope();
        }
    }

};

/*int main()
{
    int bucket_no;
    ifstream infile;
    ofstream outfile;
    infile.open("input.txt");
    //outfile.open("out.txt");
    infile>>bucket_no;
    //cout<<bucket_no;
    SymbolTable symbolTable;
    symbolTable.Enter_scope(bucket_no);
    cout<<"scopetable#1 created\n";
    string line;
    bool check;
    int command_counter=1;
    while(getline(infile, line))
    {
        istringstream iss(line);
        char c;
        string arg1, arg2;
        string arg3;
        cout<<c<<'\t'<<arg1<<'\t'<<arg2<<'\n';

        if (!(iss >> c >> arg1 >> arg2))
        {
            cout<<"Cmd "<<command_counter<<":  "<<c<<" "<<arg1<<'\n';
            command_counter++;
            // cout<<arg3<<"here";

            switch (c)
            {

            case 'L':
            {
                SymbolInfo* sym1=symbolTable.Look_up(arg1.c_str());
                //cout<<sym1->get_Name()<<" lokk";
                //cout<<sym1->get_Type();
                break;
            }
            case 'D':
                //cout<<arg1<<" in delete";
                check= symbolTable.Remove(arg1.c_str());
                if(!check) cout<< "done!";
                break;
            case 'P':

                //cout<<"\nok!";
                if (arg1 == "A")
                {
                    symbolTable.Print_All_Scope_tables();
                }
                else if (arg1 == "C")
                {
                    symbolTable.Print_Current_Scope_table();
                }
                else
                {
                    cerr << "Invalid print command: " << arg1 << endl;
                }
                break;

            case 'S':
                //cout<<arg1<<"ins";
                // cout<<stoi(arg1);
                symbolTable.Enter_scope(bucket_no);
                break;
            case 'E':
                symbolTable.Exit_scope();
                break;
            default:
                cerr << "Invalid command for: " << c << endl;
            }




            continue;

        }
        //  cout<<arg3<<"here3";

        switch (c)
        {
        case 'I':
            //cout<<arg1.c_str();
            //cout<<arg2.c_str();
            check=symbolTable.Insert(arg1.c_str(), arg2.c_str());
            if(!check) cout<< " eroor done!";
            cout<<endl;
            break;



        default:
            cerr << "Invalid command: " << c << endl;
        }
    }
    // symbolTable.Print_All_Scope_tables();






    infile.close();
    //outfile.close();
    return 0;

}*/


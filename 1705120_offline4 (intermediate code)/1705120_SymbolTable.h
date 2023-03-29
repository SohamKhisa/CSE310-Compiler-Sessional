#include <iostream>
#include <cstring>
#include <cstdlib>
#include <cmath>
#include <fstream>
#include <algorithm>
#include <vector>

using namespace std;

class SymbolInfo;

class Property
{
public:
    bool isarray;
    int arraysize=0, ithparam=0;
    vector<SymbolInfo*> list;
    string vartype, datatype, status;           //status = "defined" / "declared"
};                                              // vartype = "variable"/"function"/"parameter"

class SymbolInfo
{
    string name, type;          //name=key, type=value
    SymbolInfo *next;
    friend class ScopeTable;
public:
    Property properties;
    string code;
    string assembly, index;             //assembly it stores the assembly name of a variable.
    SymbolInfo() {
        this->name = "";
        this->type = "";
        this->next = nullptr;
    }
    SymbolInfo(string name, string type) {
        this->name = name;
        this->type = type;
        this->next = nullptr;
    }
    ~SymbolInfo() {
        SymbolInfo *curr = next;
        SymbolInfo *temp;
        while(curr != nullptr){
            temp = curr->next;
            free(curr);
            curr = temp;
        }
    }
    void setName(string name) {
        this->name = name;
    }
    string getName() {
        return name;
    }
    string getType() {
        return type;
    }
};

class ScopeTable
{
    string id;
    int scopeid;
    int childid;
    int nbuckets;
    ScopeTable *parent;
    SymbolInfo **elements;
public:
    ScopeTable(int n) {
        id = "";
        nbuckets = n;
        childid = 0;
        scopeid = 0;
        parent = nullptr;
        elements = new SymbolInfo*[nbuckets];
        for(int i=0; i<nbuckets; i++) {
            elements[i] = new SymbolInfo();
        }
    }

    ~ScopeTable()
    {
        for(int i=0; i<nbuckets; i++) {
            delete elements[i];
        }
    }

    ScopeTable *getParent()
    {
        return parent;
    }

    void setParent(ScopeTable *parent)
    {
        this->parent = parent;
    }

    int getnBuckets()
    {
        return nbuckets;
    }

    string getID()
    {
        return id;
    }

    int hashfunction(string key) {
        int sum = 0;
        for(int i=0; i<key.length(); i++) {
            int k = static_cast<int>(key[i]);
            sum = (sum + k) % nbuckets;
        }
        return sum;
    }

    void setscopeID()
    {
        if(parent==nullptr) {
            scopeid = 0;
            id = to_string(scopeid);
            return;
        }
        else {
            scopeid = parent->scopeid+1;
            id = to_string(scopeid);
        }
    }

    SymbolInfo *lookup(string key)
    {
        if(key.empty()) return nullptr;
        int col = 0;
        int bucket = hashfunction(key);
        SymbolInfo *last = elements[bucket];
        while(last != nullptr) {
            if(last->name == key) {
                //cout << "Found in ScopeTable# " << id << " at position " << bucket << ", " << col << endl << endl;
                //filewriter << "Found in ScopeTable# " << id << " at position " << bucket << ", " << col << endl << endl;
                return last;
            }
            col++;
            last = last->next;
        }
        last = nullptr;
        delete last;
        /*if(call==false) {
            filewriter << "Not found" << endl << endl;
            cout << "Not found" << endl << endl;
        }*/
        return nullptr;
    }

    bool inSert(string key, string val) {
        int c = 0;
        int bucket = hashfunction(key);
        if(elements[bucket]->name.empty()) {
            elements[bucket]->name = key;
            elements[bucket]->type = val;
        }
        else {
            c = 1;
            SymbolInfo *e = new SymbolInfo(key, val);
            SymbolInfo *last = elements[bucket];
            if(last->name == key) {
                //filewriter << "\n" << key << " already exists in current ScopeTable" << endl;
                return false;
            }
            while(last->next != nullptr) {
                if(last->next->name == key) {
                    //filewriter << "\n" << key << " already exists in current ScopeTable" << endl;
                    return false;
                }
                last = last->next;
                c++;
            }
            last->next = new SymbolInfo();
            last->next = e;
        }
        return true;
    }

    bool inSert(string key, string val, Property prop) {
        int c = 0;
        int bucket = hashfunction(key);
        if(elements[bucket]->name.empty()) {
            elements[bucket]->name = key;
            elements[bucket]->type = val;
            elements[bucket]->properties = prop;
        }
        else {
            c = 1;
            SymbolInfo *e = new SymbolInfo(key, val);
            e->properties = prop;
            SymbolInfo *last = elements[bucket];
            if(last->name == key) {
                //filewriter << "\n" << key << " already exists in current ScopeTable" << endl;
                return false;
            }
            while(last->next != nullptr) {
                if(last->next->name == key) {
                    //filewriter << "\n" << key << " already exists in current ScopeTable" << endl;
                    return false;
                }
                last = last->next;
                c++;
            }
            last->next = new SymbolInfo();
            last->next = e;
        }
        return true;
    }

    bool inSert(string key, string val, Property prop, string assembly) {
        int c = 0;
        int bucket = hashfunction(key);
        if(elements[bucket]->name.empty()) {
            elements[bucket]->name = key;
            elements[bucket]->type = val;
            elements[bucket]->properties = prop;
            elements[bucket]->assembly = assembly;
        }
        else {
            c = 1;
            SymbolInfo *e = new SymbolInfo(key, val);
            e->properties = prop;
            e->assembly = assembly;
            SymbolInfo *last = elements[bucket];
            if(last->name == key) {
                //filewriter << "\n" << key << " already exists in current ScopeTable" << endl;
                return false;
            }
            while(last->next != nullptr) {
                if(last->next->name == key) {
                    //filewriter << "\n" << key << " already exists in current ScopeTable" << endl;
                    return false;
                }
                last = last->next;
                c++;
            }
            last->next = new SymbolInfo();
            last->next = e;
        }
        return true;
    }

    bool del(string key)
    {
        SymbolInfo *target = new SymbolInfo();
        target = lookup(key);
        if(target == nullptr) {
            cout << key << " not found" << endl;
            //filewriter << key << " not found" << endl << endl;
            return false;
        }
        int col = 0;
        int bucket = hashfunction(key);
        SymbolInfo *curr = elements[bucket];
        if(elements[bucket]->name == key) {
            SymbolInfo *nxt = elements[bucket]->next;
            SymbolInfo *nxtnxt = nullptr;
            if(nxt != nullptr)
                nxtnxt = nxt->next;
            if(nxt==nullptr) {
                curr->name = "";
                curr->type = "";
            }
            else {
                curr->name = nxt->name;
                curr->type = nxt->type;
                curr->properties = nxt->properties;         //Previously showed bad:allocation error;
                // for(auto i=nxt->properties.list.begin(); i!=nxt->properties.list.end(); i++) {
                //     curr->properties.list.push_back((*i));
                // }
                // curr->properties.vartype = nxt->properties.vartype;
                // curr->properties.datatype = nxt->properties.datatype;
                // curr->properties.status = nxt->properties.status;
                // curr->properties.arraysize = nxt->properties.arraysize;
                // curr->properties.isarray = nxt->properties.isarray;
            }
            curr->next = nxtnxt;
            nxt = nullptr;
            delete nxt;
        }
        else {
            SymbolInfo *prev = nullptr;
            SymbolInfo *x = elements[bucket];
            while(x->name != key) {
                prev = x;
                x = x->next;
                col++;
            }
            if(prev != nullptr)
                prev->next = x->next;
            x = nullptr;
            delete x;
        }
        //cout << "Deleted Entry " << bucket << ", " << col << " from current ScopeTable" << endl << endl;
        //filewriter << "Deleted Entry " << bucket << ", " << col << " from current ScopeTable" << endl << endl;
        return true;
    }

    void print(ofstream &filewriter)
    {
        filewriter << endl;
        filewriter << "ScopeTable # " << id << endl;
        for (int i=0; i<nbuckets; i++) {
            SymbolInfo *ptr = elements[i];
            if(!ptr->name.empty()) {
                filewriter << " " << i << " --> ";
            }
            while(ptr != nullptr) {
                if(!ptr->name.empty()) {
                    filewriter << "< " << ptr->name << " , " << ptr->type << " > ";
                }
                ptr = ptr->next;
                if(ptr == nullptr && !elements[i]->name.empty()) {
                    filewriter << endl;
                }
            }
        }
    }
};





class SymbolTable                       //the stack manager
{
    ScopeTable *current;
public:
    SymbolTable(int n)
    {
        current = new ScopeTable(n);
        current->setscopeID();
    }

    ~SymbolTable()
    {
        ScopeTable *curr = current;
        ScopeTable *temp = nullptr;
        int cnt = 0;
        while(curr != nullptr) {
            temp = curr->getParent();
            delete curr;
            curr = temp;
        }
        curr = nullptr;
        delete curr;
    }

    void enter_scop()
    {
        ScopeTable *nsc = new ScopeTable(current->getnBuckets());
        nsc->setParent(current);
        nsc->setscopeID();
        current = nsc;
        nsc = nullptr;
        delete nsc;
    }

    void exit_scop()
    {
        ScopeTable *temp = current;
        current = temp->getParent();
        temp = nullptr;
        delete temp;
    }

    bool inSert(string key, string val)
    {
        return current->inSert(key, val);
    }

    bool insertPrevious(string key, string val, Property prop)
    {
        ScopeTable *psc = current->getParent();
        if(psc!=nullptr)
            return psc->inSert(key, val, prop);
        return false;
    }

    bool inSert(string key, string val, Property prop)
    {
        return current->inSert(key, val, prop);
    }

    bool inSert(string key, string val, Property prop, string assembly)
    {
        return current->inSert(key, val, prop, assembly);
    }

    bool reMove(string key)
    {
        return current->del(key);
    }

    bool removePrevious(string key) {
        ScopeTable *psc = current->getParent();
        if(psc!=nullptr)
            return psc->del(key);
        return false;
    }

    SymbolInfo *lookup(string key)
    {
        ScopeTable *iter = current;
        SymbolInfo *ret = nullptr;
        while(iter != nullptr) {
            ret = iter->lookup(key);
            iter = iter->getParent();
            if((ret!=nullptr) && (ret->getName()==key)) {
                return ret;
            }
        }
        iter = nullptr;
        //cout << "Not found" << endl << endl;
        //f << "Not found" << endl << endl;
        delete iter;
        return ret;
    }

    SymbolInfo *lookupPrevious(string key)
    {
        ScopeTable *iter = current->getParent();
        SymbolInfo *ret = nullptr;
        while(iter != nullptr) {
            ret = iter->lookup(key);
            iter = iter->getParent();
            if((ret!=nullptr) && (ret->getName()==key)) {
                return ret;
            }
        }
        iter = nullptr;
        //cout << "Not found" << endl << endl;
        //f << "Not found" << endl << endl;
        delete iter;
        return ret;
    }

    void print_currtable(ofstream &f)
    {
        f << endl;
        current->print(f);
        f << endl;
    }

    void print_alltable(ofstream &f)
    {
        ScopeTable *hashtable = current;
        while(hashtable != nullptr) {
            f << endl;
            hashtable->print(f);
            hashtable = hashtable->getParent();
            f << endl;
        }
    }

    string getID() {
        return current->getID();
    }
};
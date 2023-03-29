#include <iostream>
#include <bits/stdc++.h>

using namespace std;

class SymbolInfo
{
    string name, type;          //name=key, type=value
    SymbolInfo *next;
    friend class ScopeTable;
public:
    SymbolInfo() {
        this->name = "";
        this->type = "";
        this->next = nullptr;
    }
    SymbolInfo(string name, string type) {
        this->name = name;
        this->type = type;
        next = nullptr;
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
    string getName() {
        return name;
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
    ScopeTable(int n);
    ~ScopeTable();
    int hashfunction(string key);
    void setscopeID();
    bool inSert(string key, string val, ofstream &f);
    SymbolInfo *lookup(string key, ofstream &filewriter, bool call=false);
    bool del(string key, ofstream &f);
    void print(ofstream &f);
    ScopeTable *getParent();
    void setParent(ScopeTable *parent);
    int getnBuckets();
    string getID();
};

ScopeTable::ScopeTable(int n) {
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

ScopeTable::~ScopeTable()
{
    for(int i=0; i<nbuckets; i++) {
        delete elements[i];
    }
}

ScopeTable *ScopeTable::getParent()
{
    return parent;
}

void ScopeTable::setParent(ScopeTable *parent)
{
    this->parent = parent;
}

int ScopeTable::getnBuckets()
{
    return nbuckets;
}

string ScopeTable::getID()
{
    return id;
}

int ScopeTable::hashfunction(string key) {
    int sum = 0;
    for(int i=0; i<key.length(); i++) {
        int k = static_cast<int>(key[i]);
        sum = (sum + k) % nbuckets;
    }
    return sum;
}

void ScopeTable::setscopeID()
{
    if(parent==nullptr) {
        scopeid = 1;
        id = to_string(scopeid);
        return;
    }
    parent->childid += 1;
    scopeid = parent->childid;
    id = parent->id + "." + to_string(scopeid);
}

SymbolInfo *ScopeTable::lookup(string key, ofstream &filewriter, bool call)
{
    if(key.empty()) return nullptr;
    int col = 0;
    int bucket = hashfunction(key);
    SymbolInfo *last = elements[bucket];
    while(last != nullptr) {
        if(last->name == key) {
            cout << "Found in ScopeTable# " << id << " at position " << bucket << ", " << col << endl << endl;
            filewriter << "Found in ScopeTable# " << id << " at position " << bucket << ", " << col << endl << endl;
            return last;
        }
        col++;
        last = last->next;
    }
    last = nullptr;
    delete last;
    if(call==false) {
        filewriter << "Not found" << endl << endl;
        cout << "Not found" << endl << endl;
    }
    return nullptr;
}

bool ScopeTable::inSert(string key, string val, ofstream &filewriter) {
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
            filewriter << "\n" << key << " already exists in current ScopeTable" << endl;
            return false;
        }
        while(last->next != nullptr) {
            if(last->next->name == key) {
                filewriter << "\n" << key << " already exists in current ScopeTable" << endl;
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

bool ScopeTable::del(string key, ofstream &filewriter)
{
    SymbolInfo *target = new SymbolInfo();
    target = lookup(key, filewriter);
    if(target == nullptr) {
        cout << key << " not found" << endl << endl;
        filewriter << key << " not found" << endl << endl;
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
    cout << "Deleted Entry " << bucket << ", " << col << " from current ScopeTable" << endl << endl;
    filewriter << "Deleted Entry " << bucket << ", " << col << " from current ScopeTable" << endl << endl;
    return true;
}

void ScopeTable::print(ofstream &filewriter)
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
                filewriter << "< " << ptr->name << " : " << ptr->type << "> ";
            }
            ptr = ptr->next;
            if(ptr == nullptr && !elements[i]->name.empty()) {
                filewriter << endl;
            }
        }
    }
}


class SymbolTable                       //the stack manager
{
    ScopeTable *current;
public:
    SymbolTable(int n);
    ~SymbolTable();
    void enter_scop();
    void exit_scop();
    bool inSert(string key, string val, ofstream &f);
    bool reMove(string key, ofstream &f);
    SymbolInfo *lookup(string key, ofstream &f);
    void print_currtable(ofstream &f);
    void print_alltable(ofstream &f);
};

SymbolTable::SymbolTable(int n)
{
    current = new ScopeTable(n);
    current->setscopeID();
}

SymbolTable::~SymbolTable()
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

void SymbolTable::enter_scop()
{
    ScopeTable *nsc = new ScopeTable(current->getnBuckets());
    nsc->setParent(current);
    nsc->setscopeID();
    current = nsc;
    nsc = nullptr;
    delete nsc;
}

void SymbolTable::exit_scop()
{
    ScopeTable *temp = current;
    current = temp->getParent();
    temp = nullptr;
    delete temp;
}

bool SymbolTable::inSert(string key, string val, ofstream &file)
{
    return current->inSert(key, val, file);
}

bool SymbolTable::reMove(string key, ofstream &file)
{
    return current->del(key, file);
}

SymbolInfo *SymbolTable::lookup(string key, ofstream &f)
{
    ScopeTable *iter = current;
    SymbolInfo *ret = nullptr;
    while(iter != nullptr) {
        ret = iter->lookup(key, f, true);
        iter = iter->getParent();
        if((ret!=nullptr) && (ret->getName()==key)) {
            return ret;
        }
    }
    iter = nullptr;
    cout << "Not found" << endl << endl;
    f << "Not found" << endl << endl;
    delete iter;
    return ret;
}

void SymbolTable::print_currtable(ofstream &f)
{
    current->print(f);
}

void SymbolTable::print_alltable(ofstream &f)
{
    ScopeTable *hashtable = current;
    while(hashtable != nullptr) {
        hashtable->print(f);
        hashtable = hashtable->getParent();
    }
}
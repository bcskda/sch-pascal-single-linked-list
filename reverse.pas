Program List;

{ Section Type }

type
    _T = char;
    Pmlist_el= ^mlist_el;
    mlist_el = record
        value: _T;
        next: Pmlist_el;
    end;
    mlist = record // Try use Fake Head
        first: Pmlist_el;
        last: Pmlist_el;
        size: integer;
    end;
    Pmlist = ^mlist;

{ Section Common func }

procedure swap(var l: pointer; var r: pointer);
var
    t: pointer;
begin
    t := l;
    l := r;
    r := t;
end;

{ Section Memory }

function new_list(): Pmlist;
var
    ls: Pmlist;
begin
    new(ls);
    new(ls^.first); // FH, He Comes
    ls^.first^.next := nil; // Dont fill .value
    ls^.last := ls^.first;
    ls^.size := 0;
    new_list := ls;
end;

procedure free_list(var ls: Pmlist);
var
    i, j: Pmlist_el;
begin
    i := ls^.first^.next; // Keep fake head
    while i <> nil do begin
        j := i;
        i := i^.next;
        dispose(j);
        dec(ls^.size);
    end;
    ls^.first^.next := nil;
    ls^.last := nil;
end;

{ Section I/O }

procedure print_list(const ls: PMlist);
var
    i: Pmlist_el;
begin
    writeln('{');
    writeln('  "size":"', ls^.size, '",');
    write('  "data": [ ');
    i := ls^.first^.next;
    while i <> nil do begin
        if i^.next <> nil then
            write('"', i^.value, '", ')
        else
            write('"', i^.value, '" ');
        i := i^.next;
    end;
    writeln(']');
    writeln('}');
end;

{ Section Push/Pop }

procedure push_back(var ls: Pmlist; const value: _T);
begin
    new(ls^.last^.next);
    ls^.last^.next^.next := nil;
    ls^.last^.next^.value := value;
    ls^.last := ls^.last^.next;
    inc(ls^.size);
end;

procedure push_front(var ls: Pmlist; const value: _T);
var
    t: Pmlist_el;
begin
    new(t);
    swap(ls^.first^.next, t);
    ls^.first^.next^.next := t;
    ls^.first^.next^.value := value;
    inc(ls^.size);
end;

procedure pop_back(var ls: Pmlist);
var
    i, j: Pmlist_el;
begin
    if ls^.first^.next = nil then // empty
        exit;
    i := ls^.first^.next;
    while i^.next <> nil do begin
        j := i;
        i := i^.next;
    end; // Now pre-last element lies at j
    dispose(j^.next);
    j^.next := nil;
    ls^.last := j;
    dec(ls^.size);
end;

procedure pop_front(var ls: Pmlist);
var
    t: Pmlist_el;
begin
    if ls^.first^.next = nil then // empty
        exit;
    t := ls^.first^.next;
    ls^.first^.next := t^.next;
    dispose(t);
    dec(ls^.size);
end;

{ Section Algorithm }

procedure reverse(var ls: Pmlist);
var
    i, pre: Pmlist_el;
begin
    if ls^.first^.next = nil then // empty
        exit;
    if ls^.first^.next^.next = nil then // has 1 element
        exit;
    pre := ls^.first^.next;
    i := pre^.next;
    ls^.first^.next := ls^.last; // FH points to former tail
    ls^.last := pre;  // 1st actual element...
    pre^.next := nil; // ...becomes tail
    while i <> nil do begin
        swap(pre, i^.next);
        swap(i, pre);
    end;
end;

procedure sort(var ls: Pmlist);
var
    p, i, n: Pmlist_el;
    f: boolean;
begin
    if ls^.first^.next = nil then
        exit;
    f := true;
    while f do begin
        f := false;
        p := ls^.first; // FH
        i := p^.next; // 1st actual element
        n := i^.next; // 2nd actual element, possibly nil
        while n <> nil do begin
            if i^.value > n^.value then begin
                f := true;
                p^.next := n;
                i^.next := n^.next;
                n^.next := i;
                swap(i, n);
            end;
            p := i;
            i := n;
            n := n^.next;
        end;
    end;
    ls^.last := i; // In case swapped last & pre-last
end;

{ Section Main }

var
    ls: Pmlist;

begin
    writeln('Init:');
    ls := new_list();
    print_list(ls);
    writeln;

    writeln('Push back:');
    push_back(ls, 'a');
    push_back(ls, 'b');
    push_back(ls, 'c');
    print_list(ls);
    writeln;

    writeln('Pop back:');
    pop_back(ls);
    print_list(ls);
    writeln;

    writeln('Push front:');
    push_front(ls, 'x');
    push_front(ls, 'y');
    push_front(ls, 'z');
    print_list(ls);
    writeln;

    writeln('Pop front:');
    pop_front(ls);
    print_list(ls);
    writeln;

    writeln('Reverse:');
    reverse(ls);
    print_list(ls);
    writeln;

    writeln('Sort:');
    sort(ls);
    print_list(ls);
    writeln;

    writeln('Extra push front:');
    push_front(ls, '!');
    print_list(ls);
    writeln;

    writeln('Extra push back:');
    push_back(ls, '#');
    print_list(ls);
    writeln;

    writeln('Extra sort:');
    sort(ls);
    print_list(ls);
    writeln;

    writeln('Extra reverse:');
    reverse(ls);
    print_list(ls);
    writeln;

    writeln('Free:');
    free_list(ls);
    print_list(ls);
    writeln;

    writeln('Try pop back empty:');
    pop_back(ls);
    print_list(ls);
    writeln;
    
    writeln('Try pop front empty:');
    pop_front(ls);
    print_list(ls);
    writeln;
    
    writeln('Try reverse empty:');
    reverse(ls);
    print_list(ls);
    writeln;
end.

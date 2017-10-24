{
    MyList.pas - Pascal module implementing simple lists
    Copyright (C) 2017  bcskda

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
}

Unit MyList;

{ Section Interface }

Interface
    type
        _T = char;
        PTMyList_el= ^TMyList_el;
        TMyList_el = record
            value: _T;
            next: PTMyList_el;
        end;
        TMyList = record // Try use Fake Head
            first: PTMyList_el;
            last: PTMyList_el;
            size: integer;
        end;
        PTMyList = ^TMyList;

    function new_list(): PTMyList;
    procedure free_list(var ls: PTMyList);

    procedure next(var i: PTMyList_el);

    procedure print_list(const ls: PTMyList);

    procedure push_back(var ls: PTMyList; const value: _T);
    procedure push_front(var ls: PTMyList; const value: _T);
    procedure pop_back(var ls: PTMyList);
    procedure pop_front(var ls: PTMyList);

    procedure insert(var ls: PTMyList; index: integer; const value: _T; count: integer);
    procedure insert(var ls: PTMyList; index: integer; const value: _T);
    procedure remove(var ls: PTMyList; index: integer; count: integer);
    procedure remove(var ls: PTMyList; index: integer);

    procedure reverse(var ls: PTMyList);
    procedure sort(var ls: PTMyList);

    procedure MyList_PerfTest();

Implementation
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

    function new_list(): PTMyList;
    var
        ls: PTMyList;
    begin
        new(ls);
        new(ls^.first); // FH, He Comes
        ls^.first^.next := nil; // Dont fill .value
        ls^.last := ls^.first;
        ls^.size := 0;
        new_list := ls;
    end;

    procedure free_list(var ls: PTMyList);
    var
        i, j: PTMyList_el;
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

    { Section Iterator }
    procedure next(var i: PTMyList_el);
    begin
        i := i^.next;
    end;
    
    { Section I/O }

    procedure print_list(const ls: PTMyList);
    var
        i: PTMyList_el;
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

    procedure push_back(var ls: PTMyList; const value: _T);
    begin
        new(ls^.last^.next);
        ls^.last^.next^.next := nil;
        ls^.last^.next^.value := value;
        ls^.last := ls^.last^.next;
        inc(ls^.size);
    end;

    procedure push_front(var ls: PTMyList; const value: _T);
    begin
        insert(ls, 1, value);
    end;

    procedure pop_back(var ls: PTMyList);
    var
        i, j: PTMyList_el;
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

    procedure pop_front(var ls: PTMyList);
    begin
        remove(ls, 1);
    end;

    procedure insert(var ls: PTMyList; index: integer; const value: _T; count: integer);
    var
        i, p: PTMyList_el;
        j: integer;
    begin
        if (index > ls^.size + 1) then // TODO handle
            exit;
        if (count <= 0) then // No effect
            exit;
        i := ls^.first;
        j := 0;
        while (j < index - 1) do begin
            next(i);
            inc(j);
        end;
        while (count > 0) do begin
            p := i^.next;
            new(i^.next);
            i^.next^.next := p;
            i^.next^.value := value;
            inc(ls^.size);
            next(i);
            dec(count);
        end;
        if (p = nil) then
            ls^.last := i;
    end;

    procedure insert(var ls: PTMyList; index: integer; const value: _T);
    begin
        insert(ls, index, value, 1);
    end;

    procedure remove(var ls: PTMyList; index: integer; count: integer);
    var
        i, p: PTMyList_el;
        j: integer;
    begin
        if ((index > ls^.size) or (count <= 0)) then // No effect
            exit;
        i := ls^.first;
        j := 0;
        while (j < index - 1) do begin
            next(i);
            inc(j);
        end;
        while (count > 0) do begin
            p := i^.next;
            i^.next := p^.next;
            dec(ls^.size);
            dispose(p);
            dec(count);
        end;
        if (i^.next = nil) then
            ls^.last := i;
    end;

    procedure remove(var ls: PTMyList; index: integer);
    begin
        remove(ls, index, 1);
    end;
    
    { Section Algorithm }

    procedure reverse(var ls: PTMyList);
    var
        i, pre: PTMyList_el;
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

    procedure sort(var ls: PTMyList);
    var
        p, i, n: PTMyList_el;
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

    { Section Tests }
    procedure MyList_PerfTest();
        var
            ls: PTMyList;

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

            writeln('Remove 2 at #2:');
            remove(ls, 2, 2);
            print_list(ls);
            writeln;

            writeln('Extra sort:');
            sort(ls);
            print_list(ls);
            writeln;

            writeln('Add 2 at #4:');
            insert(ls, 4, '@', 2);
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

        end;
end.

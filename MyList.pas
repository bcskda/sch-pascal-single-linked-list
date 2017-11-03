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
        TProcedure_pointer = procedure(var p: pointer);
        TIntFunc_pointer_pointer = function(a, b: pointer): integer;
        PTMyList_el = ^TMyList_el;
        TMyList_el = record
            value: pointer;
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

    procedure push_back(var ls: PTMyList; const value: pointer);
    procedure push_front(var ls: PTMyList; const value: pointer);
    procedure pop_back(var ls: PTMyList);
    procedure pop_front(var ls: PTMyList);

    procedure insert(var ls: PTMyList; index: integer; const value: pointer; count: integer);
    procedure insert(var ls: PTMyList; index: integer; const value: pointer);
    procedure remove(var ls: PTMyList; index: integer; count: integer);
    procedure remove(var ls: PTMyList; index: integer);

    procedure reverse(var ls: PTMyList);
    procedure sort(var ls: PTMyList);

    var
        ML_TNew: TProcedure_pointer;
        ML_TFree: TProcedure_pointer;
        ML_TPrint: TProcedure_pointer;
        ML_TCmp: TIntFunc_pointer_pointer;

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
            ML_TFree(j^.value);
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
            if i^.next <> nil then begin
                write('"');
                ML_TPrint(i^.value);
                write('", ')
            end
            else begin
                write('"');
                ML_TPrint(i^.value);
                write('" ')
            end;
            i := i^.next;
        end;
        writeln(']');
        writeln('}');
    end;

    { Section Push/Pop }

    procedure push_back(var ls: PTMyList; const value: pointer);
    begin
        new(ls^.last^.next);
        ls^.last^.next^.next := nil;
        ls^.last^.next^.value := value;
        ls^.last := ls^.last^.next;
        inc(ls^.size);
    end;

    procedure push_front(var ls: PTMyList; const value: pointer);
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
        ML_TFree(j^.next^.value);
        dispose(j^.next);
        j^.next := nil;
        ls^.last := j;
        dec(ls^.size);
    end;

    procedure pop_front(var ls: PTMyList);
    begin
        remove(ls, 1);
    end;

    procedure insert(var ls: PTMyList; index: integer; const value: pointer; count: integer);
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

    procedure insert(var ls: PTMyList; index: integer; const value: pointer);
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
            ML_TFree(p^.value);
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
                if ML_TCmp(i^.value, n^.value) = 0 then begin
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

end.

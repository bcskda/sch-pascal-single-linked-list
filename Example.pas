Program TestMyList;

Uses MyList;

type
    _T = char;

procedure new_t(var p: pointer);
var
    fp: ^_T;
begin
    fp := p;
    new(fp);
    p := fp;
end;

procedure free_t(var p: pointer);
var
    fp: ^_T;
begin
    fp := p;
    dispose(fp);
end;

procedure print_t(var p: pointer);
var
    fp: ^_T;
begin
    fp := p;
    write(fp^);
end;

function cmp_t(a, b: pointer): integer;
var
    fpa, fpb: ^_T;
begin
    fpa := a;
    fpb := b;
    if (fpa^ > fpb^) then
        cmp_t := 1
    else if (fpa^ < fpb^) then
        cmp_t := -1
    else
        cmp_t := 0;
end;


procedure PerfTest();
var
    ls: PTMyList;
    fp: ^_T;
begin
    writeln('Init:');
    ls := new_list();
    print_list(ls);
    writeln;

    writeln('Push back:');
    new(fp);
    fp^ := 'a';
    push_back(ls, fp);
    new(fp);
    fp^ := 'b';
    push_back(ls, fp);
    new(fp);
    fp^ := 'c';
    push_back(ls, fp);
    print_list(ls);
    writeln;

    writeln('Pop back:');
    pop_back(ls);
    print_list(ls);
    writeln;

    writeln('Push front:');
    new(fp);
    fp^ := 'x';
    push_front(ls, fp);
    new(fp);
    fp^ := 'y';
    push_front(ls, fp);
    new(fp);
    fp^ := 'z';
    push_front(ls, fp);
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
    new(fp);
    fp^ := '!';
    push_front(ls, fp);
    print_list(ls);
    writeln;

    writeln('Extra push back:');
    new(fp);
    fp^ := '#';
    push_back(ls, fp);
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

    {writeln('Add 2 at #4:');
    insert(ls, 4, '@', 2);
    print_list(ls);
    writeln;}

    writeln('Extra reverse:');
    reverse(ls);
    print_list(ls);
    writeln;

    writeln('Free:');
    free_list(ls);
    print_list(ls);
    writeln;
end;


begin
    ML_TNew := @new_t;
    ML_TFree := @free_t;
    ML_TPrint := @print_t;
    ML_TCmp := @cmp_t;
    PerfTest();
end.

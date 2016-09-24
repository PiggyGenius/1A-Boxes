WITH Ada.Text_IO,Ada.Integer_Text_IO,Ada.Command_Line,Ada.Strings.Unbounded,Ada.Float_Text_IO;
USE Ada.Text_IO,Ada.Integer_Text_IO,Ada.Command_Line,Ada.Strings.Unbounded,Ada.Float_Text_IO;

PACKAGE BODY Boxes IS
FILE:File_Type;

    -- This function is self explinatory, the goal is to setup the box structure and check if the values given can create a physical box.
    PROCEDURE SetUp(box: OUT TBox) IS
        i:Natural:=1;
        count,sum:Natural:=0;
        opt:Unbounded_String;
        min:Float;
    BEGIN
        IF ARGUMENT_COUNT=0 THEN
            Put_Line("Not enough options given to """&COMMAND_NAME&""". Type: """&COMMAND_NAME&" --help"" to list options.");
            RAISE DATA_ERROR;
        END IF;
        IF Argument(1)="--help" THEN
            Put_Line("Here are all the options you must use every time you run """&COMMAND_NAME&""".");New_Line;
            Put_Line("-t: Thickness of the box.");
            Put_Line("-l: Length of the box.");
            Put_Line("-w: Width of the box.");
            Put_Line("-q: Length of the box's queues.");
            Put_Line("-h: External height of the box.");
            Put_Line("-b: Internal height of the box.");
            Put_Line("-f: Name of the svg file.");
            New_Line;Put_Line("Here are the options you can use if you wish to do so:");New_Line;
            Put_Line("-m: Text you wish to carve on your box.");
            Put_Line("-s: Size of the font you want to use, default font is 36.");
            RAISE DATA_ERROR;
        END IF;
        IF ARGUMENT_COUNT<14 THEN
            Put_Line("Not enough options given to """&COMMAND_NAME&""". Type: """&COMMAND_NAME&" --help"" to list options.");
            RAISE DATA_ERROR;
        END IF;
        box.size:=36;
        -- count and sum will be used to check if mandatory options are given.
        WHILE i<=ARGUMENT_COUNT LOOP
            IF Argument(i)="-f" THEN    
                box.file_name:=To_Unbounded_String(Argument(i+1));
                count:=count+1;sum:=sum+1;
            ELSIF Argument(i)="-l" THEN
                box.length:=Float(Positive'Value(Argument(i+1)));
                count:=count+1;sum:=sum+2;
            ELSIF Argument(i)="-w" THEN
                box.width:=Float(Positive'Value(Argument(i+1)));
                count:=count+1;sum:=sum+3;
            ELSIF Argument(i)="-q" THEN
                box.queue_length:=Float(Positive'Value(Argument(i+1)));
                count:=count+1;sum:=sum+4;
            ELSIF Argument(i)="-t" THEN
                box.thickness:=Float(Positive'Value(Argument(i+1)));
                count:=count+1;sum:=sum+5;
            ELSIF Argument(i)="-h" THEN
                box.ext_height:=Float(Positive'Value(Argument(i+1)));
                count:=count+1;sum:=sum+6;
            ELSIF Argument(i)="-b" THEN
                box.int_height:=Float(Positive'Value(Argument(i+1)));
                count:=count+1;sum:=sum+7;
            ELSIF Argument(i)="-m" THEN
                box.text:=To_Unbounded_String(Argument(i+1));
            ELSIF Argument(i)="-s" THEN
                box.size:=Positive'Value(Argument(i+1));
            ELSIF Argument(i)="--help" THEN
                Put_Line(""""&Argument(i)&""" souldn't be used with other options. Type: """&COMMAND_NAME&" --help"" to list valid options.");
                RAISE DATA_ERROR;
            ELSE
                Put_Line(""""&Argument(i)&""" is not a valid option. Type: """&COMMAND_NAME&" --help"" to list valid options.");
                RAISE DATA_ERROR;
            END IF;
            i:=i+2;
        END LOOP;
        IF sum/=28 OR count/=7 THEN
            Put_Line("Some options are mandatory. Type: """&COMMAND_NAME&" --help"" to list the options.");
            RAISE DATA_ERROR;
        END IF;
        IF Length(box.text)>0 THEN
            IF Float(Length(box.text))*(Float(box.size)/1.16)>box.length THEN
                Put("The message is too large or the size of the font is too big for the length.");
                RAISE DATA_ERROR;
            END IF;
            IF Float(box.size)/1.3>box.width THEN
                Put("The message is too large or the size of the font is too big for the width.");
                RAISE DATA_ERROR;
            END IF;
        END IF;
        min:=2.0*box.thickness+box.queue_length;
        IF min=box.width AND (min=box.length OR min=box.ext_height OR min=box.int_height) THEN
            Put_Line("If 2.0*t+q=w then 2.0*t+q must be strictly lower than l,h and b.");
            RAISE DATA_ERROR;
        END IF;
        IF box.length-2.0*box.thickness<2.0*box.thickness+box.queue_length THEN
            Put_Line("The interior box cannot fit into the exterior box, l-2*t must be higher than 2*t+q.");
            RAISE DATA_ERROR;
        END IF;
        IF box.int_height>=(box.ext_height-2.0*box.thickness) THEN
            Put_Line("b must be lower than h-2*t. This box can't be created.");
            RAISE DATA_ERROR;
        END IF;
        box.ext_height:=box.ext_height/2.0;
        IF box.length<min OR box.width<min OR box.int_height<min OR box.ext_height<min  THEN
            Put_Line("w,l,h and b must be higher than 2*t+q. This box can't be created.");
            RAISE DATA_ERROR;
        END IF;
    EXCEPTION
        WHEN CONSTRAINT_ERROR => 
            Put_Line("All the options must be positive numbers. Except -f which must be a string.");
            RAISE DATA_ERROR;
    END;




    PROCEDURE SvgHeader(height,width: Float;name: Unbounded_String) IS
    BEGIN
        Create(file=>FILE,mode=>OUT_FILE,name=>To_String(name));
        Put(FILE,"<svg height=""");Put(FILE,height,exp=>0,aft=>0);
        Put(FILE,""" width=""");Put(FILE,width,exp=>0,aft=>0);Put_Line(FILE,""">");
    EXCEPTION
        WHEN END_ERROR => 
            IF Is_Open(FILE) THEN
                Close(FILE);
            END IF;
        WHEN OTHERS =>
            Put_Line("Error: couldn't create file. Try again with another file.");
    END;

    PROCEDURE InitPolygon IS
    BEGIN
        New_Line(FILE);
        Put(FILE,"<polygon points=""");
    END;

    PROCEDURE AddPoint(p: Point) IS 
    BEGIN
        Put(FILE,p.x,exp=>0,aft=>0);Put(FILE,",");Put(FILE,p.y,exp=>0,aft=>0);Put(FILE," ");
    END;

    PROCEDURE EndPolygon IS
    BEGIN
        Put_Line(FILE,""" style=""fill:none;stroke:red;stroke-width:1""/>");
    END;

    PROCEDURE DrawText(p: Point;text: String;font: Positive) IS
    BEGIN
        New_Line(FILE);
        Put(FILE,"<text x=""");Put(FILE,p.x,exp=>0,aft=>0);
        Put(FILE,""" y=""");Put(FILE,p.y,exp=>0,aft=>0);Put(FILE,""" ");
        Put(FILE,"style=""text-anchor: middle;font-family:Arial;fill:#00ff00;stroke:#000000;font-size:");
        Put(FILE,font,width=>0);Put(FILE,"px;"">");
        Put(FILE,text);Put_Line(FILE,"</text>");
    END;

    PROCEDURE SvgFooter IS
    BEGIN
        New_Line(FILE);
        Put_Line(FILE,"</svg>");
        Close(FILE);
    END;



    -- The drawBottomXXXXXX functions will draw the west,south,east and north sides of the bottom of a box.
    PROCEDURE DrawBottomWest(start: IN OUT Point;box: TBox) IS
        p:Point;
    BEGIN
        p.x:=start.x;
        p.y:=start.y;
        AddPoint(p);
        p.y:=p.y+box.margin_w+box.thickness;AddPoint(p);
        p.x:=p.x+box.thickness;AddPoint(p);
        p.y:=p.y+box.queue_length;AddPoint(p);
        p.x:=p.x-box.thickness;AddPoint(p);
        FOR i IN 1..box.count_w LOOP
            p.y:=p.y+box.queue_length;AddPoint(p);
            p.x:=p.x+box.thickness;AddPoint(p);
            p.y:=p.y+box.queue_length;AddPoint(p);
            p.x:=p.x-box.thickness;AddPoint(p);
        END LOOP;
        p.y:=p.y+box.thickness+box.margin_w;AddPoint(p);
        start.x:=p.x;
        start.y:=p.y;
    END;

    PROCEDURE DrawBottomSouth(start: IN OUT Point;box: TBox) IS
        p:Point;
    BEGIN
        p.x:=start.x;
        p.y:=start.y;
        p.x:=p.x+box.margin_l+box.thickness;AddPoint(p);
        p.y:=p.y-box.thickness;AddPoint(p);
        p.x:=p.x+box.queue_length;AddPoint(p);
        p.y:=p.y+box.thickness;AddPoint(p);
        FOR i IN 1..box.count_l LOOP
            p.x:=p.x+box.queue_length;AddPoint(p);
            p.y:=p.y-box.thickness;AddPoint(p);
            p.x:=p.x+box.queue_length;AddPoint(p);
            p.y:=p.y+box.thickness;AddPoint(p);
        END LOOP;
        p.x:=p.x+box.thickness+box.margin_l;AddPoint(p);
        start.x:=p.x;
        start.y:=p.y;
    END;

    PROCEDURE DrawBottomEast(start: IN OUT Point;box: TBox) IS
        p:Point;
    BEGIN
        p.x:=start.x;
        p.y:=start.y;
        p.y:=p.y-box.margin_w-box.thickness;AddPoint(p);
        p.x:=p.x-box.thickness;AddPoint(p);
        p.y:=p.y-box.queue_length;AddPoint(p);
        p.x:=p.x+box.thickness;AddPoint(p);
        FOR i IN 1..box.count_w LOOP
            p.y:=p.y-box.queue_length;AddPoint(p);
            p.x:=p.x-box.thickness;AddPoint(p);
            p.y:=p.y-box.queue_length;AddPoint(p);
            p.x:=p.x+box.thickness;AddPoint(p);
        END LOOP;
        p.y:=p.y-box.thickness-box.margin_w;AddPoint(p);
        start.x:=p.x;
        start.y:=p.y;
    END;

    PROCEDURE DrawBottomNorth(start: IN OUT Point;box: TBox) IS
        p:Point;
    BEGIN
        p.x:=start.x;
        p.y:=start.y;
        p.x:=p.x-box.margin_l-box.thickness;AddPoint(p);
        p.y:=p.y+box.thickness;AddPoint(p);
        p.x:=p.x-box.queue_length;AddPoint(p);
        p.y:=p.y-box.thickness;AddPoint(p);
        FOR i IN 1..box.count_l LOOP
            p.x:=p.x-box.queue_length;AddPoint(p);
            p.y:=p.y+box.thickness;AddPoint(p);
            p.x:=p.x-box.queue_length;AddPoint(p);
            p.y:=p.y-box.thickness;AddPoint(p);
        END LOOP;
        start.x:=p.x;
        start.y:=p.y;
    END;

    PROCEDURE DrawBottom(start: IN OUT Point;box: IN OUT TBox) IS
    BEGIN
        InitPolygon;
        DrawBottomWest(start,box);
        DrawBottomSouth(start,box);
        DrawBottomEast(start,box);
        DrawBottomNorth(start,box);
        EndPolygon;
    END;



    -- DrawSidesNSXXXXX functions will draw the west,east and north parts of the top and bottom sides of a box
    PROCEDURE DrawSidesNSWest(start: IN OUT Point;box: TBox) IS
        p:Point;
    BEGIN
        p.x:=start.x;
        p.y:=start.y;
        AddPoint(p);
        p.y:=p.y+box.margin_h+box.thickness;AddPoint(p);
        p.x:=p.x-box.thickness;AddPoint(p);
        p.y:=p.y+box.queue_length;AddPoint(p);
        p.x:=p.x+box.thickness;AddPoint(p);
        FOR i IN 1..box.count_h LOOP
            p.y:=p.y+box.queue_length;AddPoint(p);
            p.x:=p.x-box.thickness;AddPoint(p);
            p.y:=p.y+box.queue_length;AddPoint(p);
            p.x:=p.x+box.thickness;AddPoint(p);
        END LOOP;
        p.y:=p.y+box.thickness+box.margin_h;AddPoint(p);
        start.x:=p.x;
        start.y:=p.y;
    END;

    PROCEDURE DrawSidesNSEast(start: IN OUT Point;box: TBox) IS
        p:Point;
    BEGIN
        p.x:=start.x;
        p.y:=start.y;
        p.y:=p.y-box.margin_h-box.thickness;AddPoint(p);
        p.x:=p.x+box.thickness;AddPoint(p);
        p.y:=p.y-box.queue_length;AddPoint(p);
        p.x:=p.x-box.thickness;AddPoint(p);
        FOR i IN 1..box.count_h LOOP
            p.y:=p.y-box.queue_length;AddPoint(p);
            p.x:=p.x+box.thickness;AddPoint(p);
            p.y:=p.y-box.queue_length;AddPoint(p);
            p.x:=p.x-box.thickness;AddPoint(p);
        END LOOP;
        p.y:=p.y-box.thickness-box.margin_h;AddPoint(p);
        start.x:=p.x;
        start.y:=p.y;
    END;

    PROCEDURE DrawSidesNSNorth(start: IN OUT Point;box: TBox) IS
        p:Point;
    BEGIN
        p.x:=start.x;
        p.y:=start.y;
        p.x:=p.x-box.margin_l-box.thickness;AddPoint(p);
        p.y:=p.y-box.thickness;AddPoint(p);
        p.x:=p.x-box.queue_length;AddPoint(p);
        p.y:=p.y+box.thickness;AddPoint(p);
        FOR i IN 1..box.count_l LOOP
            p.x:=p.x-box.queue_length;AddPoint(p);
            p.y:=p.y-box.thickness;AddPoint(p);
            p.x:=p.x-box.queue_length;AddPoint(p);
            p.y:=p.y+box.thickness;AddPoint(p);
        END LOOP;
        start.x:=p.x;
        start.y:=p.y;
    END;

    PROCEDURE DrawSidesNS(start: IN OUT Point;box: TBox) IS
    BEGIN
        InitPolygon;
        DrawSidesNSWest(start,box);
        start.x:=start.x+box.length;AddPoint(start);
        DrawSidesNSEast(start,box);
        DrawSidesNSNorth(start,box);
        EndPolygon;
    END;



    -- DrawSidesWEXXXXX functions will draw the west,east and north parts of the left and right sides of a box
    PROCEDURE DrawSidesWEWest(start: IN OUT Point;box: TBox) IS
        p:Point;
    BEGIN
        p.x:=start.x;
        p.y:=start.y;
        AddPoint(p);
        p.y:=p.y+box.margin_h+box.thickness;AddPoint(p);
        p.x:=p.x+box.thickness;AddPoint(p);
        p.y:=p.y+box.queue_length;AddPoint(p);
        p.x:=p.x-box.thickness;AddPoint(p);
        FOR i IN 1..box.count_h LOOP
            p.y:=p.y+box.queue_length;AddPoint(p);
            p.x:=p.x+box.thickness;AddPoint(p);
            p.y:=p.y+box.queue_length;AddPoint(p);
            p.x:=p.x-box.thickness;AddPoint(p);
        END LOOP;
        p.y:=p.y+box.thickness+box.margin_h;AddPoint(p);
        start.x:=p.x;
        start.y:=p.y;
    END;

    PROCEDURE DrawSidesWEEast(start: IN OUT Point;box: TBox) IS
        p:Point;
    BEGIN
        p.x:=start.x;
        p.y:=start.y;
        p.y:=p.y-box.margin_h-box.thickness;AddPoint(p);
        p.x:=p.x-box.thickness;AddPoint(p);
        p.y:=p.y-box.queue_length;AddPoint(p);
        p.x:=p.x+box.thickness;AddPoint(p);
        FOR i IN 1..box.count_h LOOP
            p.y:=p.y-box.queue_length;AddPoint(p);
            p.x:=p.x-box.thickness;AddPoint(p);
            p.y:=p.y-box.queue_length;AddPoint(p);
            p.x:=p.x+box.thickness;AddPoint(p);
        END LOOP;
        p.y:=p.y-box.thickness-box.margin_h;AddPoint(p);
        start.x:=p.x;
        start.y:=p.y;
    END;

    PROCEDURE DrawSidesWENorth(start: IN OUT Point;box: TBox) IS
        p:Point;
    BEGIN
        p.x:=start.x;
        p.y:=start.y;
        p.x:=p.x-box.margin_w-box.thickness;AddPoint(p);
        p.y:=p.y-box.thickness;AddPoint(p);
        p.x:=p.x-box.queue_length;AddPoint(p);
        p.y:=p.y+box.thickness;AddPoint(p);
        FOR i IN 1..box.count_w LOOP
            p.x:=p.x-box.queue_length;AddPoint(p);
            p.y:=p.y-box.thickness;AddPoint(p);
            p.x:=p.x-box.queue_length;AddPoint(p);
            p.y:=p.y+box.thickness;AddPoint(p);
        END LOOP;
        start.x:=p.x;
        start.y:=p.y;
    END;

    PROCEDURE DrawSidesWE(start: IN OUT Point;box: TBox) IS
    BEGIN
        InitPolygon;
        DrawSidesWEWest(start,box);
        start.x:=start.x+box.width;AddPoint(start);
        DrawSidesWEEast(start,box);
        DrawSidesWENorth(start,box);
        EndPolygon;
    END;


    -- This function setups data that will be used to draw correct boxes
    PROCEDURE SetupBoxData(box: IN OUT TBox) IS
        error_w,error_l,error_h: Float;
    BEGIN
        --the box.count attribute will allow us to know the number of queues to draw
        box.count_w:=Integer((box.width-2.0*box.thickness)/box.queue_length);
        box.count_w:=(box.count_w-1)/2;
        box.count_l:=Integer((box.length-2.0*box.thickness)/box.queue_length);
        box.count_l:=(box.count_l-1)/2;
        box.count_h:=Integer((box.ext_height-2.0*box.thickness)/box.queue_length);
        box.count_h:=(box.count_h-1)/2;

        -- If thickness+margins are lower than box.queue_length, there can be a problem when cutting the box, somes parts could fall off, this error checking allow us to deal with that
        error_w:=2.0*box.thickness+box.queue_length+box.queue_length*Float(box.count_w)*2.0;
        error_l:=2.0*box.thickness+box.queue_length+box.queue_length*Float(box.count_l)*2.0;
        error_h:=2.0*box.thickness+box.queue_length+box.queue_length*Float(box.count_l)*2.0;
        IF error_w>=box.width AND error_l>=box.length AND box.count_w>0 THEN
            box.count_w:=box.count_w-1;
        END IF;
        IF error_l>=box.length AND error_h>=box.ext_height AND box.count_l>0 THEN
            box.count_l:=box.count_l-1;
        END IF;

        -- margins allow us to center the queues
        box.margin_l:=(box.length-2.0*box.thickness-box.queue_length-Float(box.count_l)*box.queue_length*2.0)/2.0;
        box.margin_w:=(box.width-2.0*box.thickness-box.queue_length-Float(box.count_w)*box.queue_length*2.0)/2.0;

        box.margin_h:=(box.ext_height-2.0*box.thickness-box.queue_length-Float(box.count_h)*box.queue_length*2.0)/2.0;
    END;
    
    PROCEDURE DrawBox(start: IN OUT Point;box: IN OUT TBox) IS
        step:Float := 10.0+box.length+box.queue_length*2.0;
    BEGIN
        SetupBoxData(box);


        DrawBottom(start,box);

        start.x:=start.x+step;
        DrawSidesNS(start,box);
        start.x:=start.x+step;
        DrawSidesNS(start,box);

        start.x:=start.x+step;
        DrawSidesWE(start,box);
        start.x:=start.x+box.width+box.queue_length*2.0;
        DrawSidesWE(start,box);
    END;

    PROCEDURE DrawBoxes(box: IN OUT TBox) IS
        start,tmp: Point;
        width,height,max: Float;
    BEGIN
        IF box.ext_height>box.int_height THEN
            IF box.ext_height>box.width THEN
                max:=box.ext_height;
            ELSE
                max:=box.width;
            END IF;
        ELSE
            IF box.int_height>box.width THEN
                max:=box.int_height;
            ELSE
                max:=box.width;
            END IF;
        END IF;

        start.x:=10.0+box.queue_length*2.0;start.y:=10.0+box.queue_length*2.0;
        height:=50.0+max*3.0+3.0*box.queue_length*2.0;
        width:=10.0+3.0*box.length+2.0*box.width+box.queue_length*2.0+4.0*(box.length+box.queue_length*2.0);

        SvgHeader(height,width,box.file_name);

        IF Length(box.text)>0 THEN
            tmp.x:=start.x+(box.length/2.0);
            tmp.y:=start.y+(box.width/2.0)+((Float(box.size)/1.3)/2.0);
            DrawText(tmp,To_String(box.text),box.size);
        END IF;

        DrawBox(start,box);

        start.x:=10.0+box.queue_length*2.0;start.y:=20.0+2.0*box.queue_length*2.0+max; 
        DrawBox(start,box);

        box.ext_height:=box.int_height;
        box.width:=box.width-2.0*box.thickness;
        box.length:=box.length-2.0*box.thickness;
        start.x:=10.0+box.queue_length*2.0;start.y:=30.0+3.0*box.queue_length*2.0+2.0*max;
        DrawBox(start,box);

        SvgFooter;
    END;


END Boxes;

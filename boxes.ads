WITH Ada.Strings.Unbounded;
USE Ada.Strings.Unbounded;

PACKAGE Boxes IS

    TYPE TBox IS RECORD
        file_name,text:Unbounded_String;
        length,width,queue_length,thickness,ext_height,int_height,margin_w,margin_l,margin_h:Float;
        count_w,count_l,count_h:Integer;
        size:Positive;
    END RECORD;
    TYPE Point IS RECORD
        x:Float;
        y:Float;
    END RECORD;

    PROCEDURE SetUp(box: OUT TBox);

    PROCEDURE SvgHeader(height,width: Float;name: Unbounded_String);
    PROCEDURE InitPolygon;
    PROCEDURE AddPoint(p: Point);
    PROCEDURE EndPolygon;
    PROCEDURE DrawText(p: Point;text: String;font: Positive);
    PROCEDURE SvgFooter;

    PROCEDURE DrawBottomWest(start: IN OUT Point;box: TBox);
    PROCEDURE DrawBottomSouth(start: IN OUT Point;box: TBox);
    PROCEDURE DrawBottomEast(start: IN OUT Point;box: TBox);
    PROCEDURE DrawBottomNorth(start: IN OUT Point;box: TBox);
    PROCEDURE DrawBottom(start: IN OUT Point;box: IN OUT TBox);

    PROCEDURE DrawSidesNSWest(start: IN OUT Point;box: TBox);
    PROCEDURE DrawSidesNSEast(start: IN OUT Point;box: TBox);
    PROCEDURE DrawSidesNSNorth(start: IN OUT Point;box: TBox);
    PROCEDURE DrawSidesNS(start: IN OUT Point;box: TBox);
    
    PROCEDURE DrawSidesWEWest(start: IN OUT Point;box: TBox);
    PROCEDURE DrawSidesWEEast(start: IN OUT Point;box: TBox);
    PROCEDURE DrawSidesWENorth(start: IN OUT Point;box: TBox);
    PROCEDURE DrawSidesWE(start: IN OUT Point;box: TBox);

    PROCEDURE SetupBoxData(box: IN OUT TBox);
    PROCEDURE DrawBox(start: IN OUT Point;box: IN OUT TBox);
    PROCEDURE DrawBoxes(box: IN OUT TBox);

END Boxes;

WITH Ada.Text_IO,Boxes;
USE Ada.text_IO,Boxes;

PROCEDURE Main IS
    box:TBox;
BEGIN
    SetUp(box);
    DrawBoxes(box);
EXCEPTION
    WHEN DATA_ERROR => RETURN;
END;

with Text_IO, Rule_Table, Symbol_Table, Ayacc_File_Names;
use  Text_IO, Rule_Table, Symbol_Table, Ayacc_File_Names;
with Ada.Strings.Fixed;                 use Ada.Strings, Ada.Strings.Fixed;

package body Goto_File is

  -- SCCS_ID : constant String := "@(#) goto_file.ada, Version 1.2";

  -- Rcs_ID : constant String := "$Header: /dc/uc/self/arcadia/ayacc/src/RCS/goto_file.a,v 1.2 1993/05/31 22:36:35 self Exp self $";

    The_File : File_Type;

    procedure Open_Write is
    begin
       if Is_Open (The_File) then
          return;
       end if;
       Create(The_File, Out_File, Get_Goto_File_Name);

       Write_Line("package " & Goto_Tables_Unit_Name & " is");
       Write_Line("");
       Write_Line("");
       Write_Line("   type Rule        is new Natural;");
       Write_Line("   type Nonterminal is new Integer;");
       Write_Line("");
       Write_Line("   type Small_Integer is range -32_000 .. 32_000;");
       Write_Line("   subtype Small_Nonterminal is Nonterminal range -32_000 .. 32_000;");
       Write_Line("");
       Write_Line("   type Goto_Entry is record");
       Write_Line("      Nonterm  : Small_Nonterminal;");
       Write_Line("      Newstate : Small_Integer;");
       Write_Line("   end record;");
       Write_Line("");
       Write_Line("   --  pragma suppress(index_check);");
       Write_Line("");
       Write_Line("   type Row is new Integer range -1 .. Integer'Last;");
       Write_Line("");
       Write_Line("   type Goto_Parse_Table is array (Row range <>) of " &
                  "Goto_Entry;");
       Write_Line("");
       Write_Line("   Goto_Matrix : constant Goto_Parse_Table :=");
       Write_Line("      ((-1, -1)  -- Dummy Entry.");
       exception
            when Name_Error | Use_Error =>
                Put_Line("Ayacc: Error Opening """ & Get_Goto_File_Name & """.");
                raise;
    end Open_Write;


    procedure Close_Write is
    begin

        -- Write the rule length array --
        Write( "   Rule_Length : constant array (Rule range" & Rule'Image(First_Rule) &
              " .." & Rule'Image(Last_Rule) & ") of Natural := (");

        for R in First_Rule..Last_Rule loop
            Write( Trim(Natural'Image(Length_of(R)),left) );
         if R = Last_Rule then
            Write_Line( ");");
         elsif R mod 23 = 0 then
            Write_Line( ",");
            Write("      ");
         else
            Write( ", ");
         end if;
        end loop;

        -- Write the lefth hand side array
        Write_Line("");
        Write("   Get_LHS_Rule : constant array (Rule range" &
              Rule'Image(First_Rule) & " .." &
        Rule'Image(Last_Rule) & ") of Nonterminal := (");

        for R in First_Rule..Last_Rule loop
         if R = Last_Rule then
            Write_Line(' ' & Grammar_Symbol'Image(Get_LHS(R)) & ");");
         elsif R = First_Rule then
            Write_Line(Grammar_Symbol'Image(Get_LHS(R)) & ',');
            Write("      ");
         elsif R mod 14 = 0 then
            Write_Line(' ' & Grammar_Symbol'Image(Get_LHS(R)) & ',');
            Write("      ");
         else
            Write(' ' & Grammar_Symbol'Image(Get_LHS(R)) & ',');
         end if;
        end loop;

        Write_Line("");
        Write_Line("end " & Goto_Tables_Unit_Name & ";");
    Close(The_File);
    end Close_Write;


    procedure Write(S: in String) is
    begin
        Put(The_File, S);
    end Write;


    procedure Write_Line(S: in String) is
    begin
    Put_Line(The_File, S);
    end Write_Line;


    procedure Write(C: in Character) is
    begin
    Put(The_File, C);
    end Write;

   procedure Write_Indented (S : in String) is
   begin
      if Col(The_File) = 1 then
         Put(The_File, "      ");
      end if;
      Put(The_File, S);
   end Write_Indented;

end Goto_File;

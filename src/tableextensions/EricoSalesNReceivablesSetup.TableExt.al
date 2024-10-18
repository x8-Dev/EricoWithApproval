tableextension 70100 EricoSalesNReceivablesSetup extends "Sales & Receivables Setup"
{
    fields
    {
        field(70000; "Customer Blocking Email"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
        field(70001; "Cust. Statement Day1 Message"; Blob)
        {
            Caption = 'Customer Statement Day 1 Message';
            DataClassification = ToBeClassified;
        }
        field(70002; "Cust. Statement Day2 Message"; Blob)
        {
            Caption = 'Customer Statement Day 2 Message';
            DataClassification = ToBeClassified;
        }
        field(70003; "Cust. Statement Day3 Message"; Blob)
        {
            Caption = 'Customer Statement Day 3 Message';
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        // Add changes to keys here
    }


    fieldgroups
    {
        // Add changes to field groups here
    }

    procedure SetDay1Message(Day1Message: Text)
    var
        OutStream: OutStream;
    begin
        Clear(Rec."Cust. Statement Day1 Message");
        Rec."Cust. Statement Day1 Message".CreateOutStream(OutStream, TEXTENCODING::UTF8);
        OutStream.WriteText(Day1Message);
        rec.Modify();
    end;

    procedure GetDay1Message() Day1Reminder: Text
    var
        TypeHelper: Codeunit "Type Helper";
        InStream: InStream;
    begin
        CalcFields("Cust. Statement Day1 Message");
        "Cust. Statement Day1 Message".CreateInStream(InStream, TEXTENCODING::UTF8);
        exit(TypeHelper.TryReadAsTextWithSepAndFieldErrMsg(InStream, TypeHelper.LFSeparator(), FieldName("Cust. Statement Day1 Message")));
    end;

    procedure SetDay2Message(Day2Message: Text)
    var
        OutStream: OutStream;
    begin
        Clear(Rec."Cust. Statement Day2 Message");
        Rec."Cust. Statement Day2 Message".CreateOutStream(OutStream, TEXTENCODING::UTF8);
        OutStream.WriteText(Day2Message);
        rec.Modify();
    end;

    procedure GetDay2Message() Day2Reminder: Text
    var
        TypeHelper: Codeunit "Type Helper";
        InStream: InStream;
    begin
        CalcFields("Cust. Statement Day2 Message");
        "Cust. Statement Day2 Message".CreateInStream(InStream, TEXTENCODING::UTF8);
        exit(TypeHelper.TryReadAsTextWithSepAndFieldErrMsg(InStream, TypeHelper.LFSeparator(), FieldName("Cust. Statement Day2 Message")));
    end;

    procedure SetDay3Message(Day3Message: Text)
    var
        OutStream: OutStream;
    begin
        Clear(Rec."Cust. Statement Day3 Message");
        Rec."Cust. Statement Day3 Message".CreateOutStream(OutStream, TEXTENCODING::UTF8);
        OutStream.WriteText(Day3Message);
        rec.Modify();
    end;

    procedure GetDay3Message() Day3Reminder: Text
    var
        TypeHelper: Codeunit "Type Helper";
        InStream: InStream;
    begin
        CalcFields("Cust. Statement Day3 Message");
        "Cust. Statement Day3 Message".CreateInStream(InStream, TEXTENCODING::UTF8);
        exit(TypeHelper.TryReadAsTextWithSepAndFieldErrMsg(InStream, TypeHelper.LFSeparator(), FieldName("Cust. Statement Day3 Message")));
    end;






    var
        myInt: Integer;
}
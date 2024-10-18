table 70100 CustomerDueReqstToApprove
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = ToBeClassified;
            AutoIncrement = true;
        }
        field(2; "Document No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Customer No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Sender ID"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(5; "Approved By"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Status"; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = Approved,Rejected,New;
        }
        field(7; "Date Approved"; Date)
        {
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        // Add changes to field groups here
    }

    var
        myInt: Integer;

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

}
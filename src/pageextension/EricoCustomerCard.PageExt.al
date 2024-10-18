pageextension 70102 EricoCustomerCard extends "Customer Card"
{
    layout
    {
        addafter("E-Mail")
        {
            field("Customer Statement Email"; Rec."Customer Statement Email")
            {
                ApplicationArea = All;
            }
        }
        modify("Salesperson Code")
        {
            trigger OnAfterValidate()
            var
                Dimension: Record "Default Dimension";
            begin
                GeneralLedgerSetup.Get();
                if Rec."Salesperson Code" = '' then begin
                    Dimension.SetRange("Table ID", 18);
                    Dimension.SetRange("No.", rec."No.");
                    Dimension.SetRange("Dimension Code", GeneralLedgerSetup."Shortcut Dimension 8 Code");
                    if Dimension.FindFirst() then begin
                        Dimension.Delete();
                    end;
                end else begin
                    if xRec."Salesperson Code" <> rec."Salesperson Code" then begin
                        Dimension.SetRange("Table ID", 18);
                        Dimension.SetRange("No.", rec."No.");
                        Dimension.SetRange("Dimension Code", GeneralLedgerSetup."Shortcut Dimension 8 Code");
                        if Dimension.FindFirst() then begin
                            Dimension."Dimension Value Code" := rec."Salesperson Code";
                            Dimension.Modify();
                        end else begin
                            Dimension."No." := Rec."No.";
                            Dimension."Table ID" := 18;
                            Dimension."Dimension Code" := GeneralLedgerSetup."Shortcut Dimension 8 Code";
                            Dimension."Dimension Value Code" := rec."Salesperson Code";
                            Dimension."Value Posting" := Dimension."Value Posting"::"Code Mandatory";
                            Dimension.Insert();
                        end;
                    end;
                end;
            end;
        }
    }


    actions
    {
        // Add changes to page actions here
    }

    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        myInt: Integer;
}
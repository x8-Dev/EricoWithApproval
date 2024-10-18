pageextension 70103 EricoDefaultDimensions extends "Default Dimensions"
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        // Add changes to page actions here
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
    begin
        UpdateSalesPersonInCustomer();
    end;

    trigger OnModifyRecord(): Boolean
    var
    begin
        UpdateSalesPersonInCustomer();
    end;

    trigger OnDeleteRecord(): Boolean
    var
    begin
        GeneralLedgerSetup.Get();
        if Rec."Parent Type" = rec."Parent Type"::Customer then begin
            if Customer.Get(Rec."No.") then
                if rec."Dimension Code" = GeneralLedgerSetup."Shortcut Dimension 8 Code" then begin
                    Customer."Salesperson Code" := '';
                    Customer.Modify();
                end;
        end;
    end;

    local procedure UpdateSalesPersonInCustomer()
    var
    begin
        GeneralLedgerSetup.Get();
        if Rec."Parent Type" = rec."Parent Type"::Customer then begin
            if Customer.Get(Rec."No.") then
                if rec."Dimension Code" = GeneralLedgerSetup."Shortcut Dimension 8 Code" then begin
                    Customer."Salesperson Code" := Rec."Dimension Value Code";
                    Customer.Modify();
                end;
        end;
    end;

    var
        Customer: Record Customer;
        GeneralLedgerSetup: Record "General Ledger Setup";
}
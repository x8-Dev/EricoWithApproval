pageextension 70108 EricoPostedSalesCreditMemos extends "Posted Sales Credit Memos"
{
    layout
    {
        addafter("Sell-to Customer No.")
        {
            field(OrderNo; OrderNo)
            {
                ApplicationArea = All;
                Caption = 'Order No.';
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    trigger OnAfterGetRecord()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        SalesInvoiceHeader.SetRange("No.", rec."Applies-to Doc. No.");
        if SalesInvoiceHeader.FindFirst() then
            OrderNo := SalesInvoiceHeader."Order No.";

    end;

    var
        OrderNo: Code[20];
}
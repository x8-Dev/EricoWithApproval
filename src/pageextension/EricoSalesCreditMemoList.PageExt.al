pageextension 70107 EricoSalesCreditMemos extends "Sales Credit Memos"
{
    layout
    {
        addafter("External Document No.")
        {
            field(OrderNo; OrderNo)
            {
                ApplicationArea = All;
                Caption = 'Order No.';
            }
            field(ShipmentNo; ShipmentNo)
            {
                ApplicationArea = All;
                Caption = 'Shipment No.';
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
        SalesShipmentHeader: Record "Sales Shipment Header";
    begin
        SalesInvoiceHeader.SetRange("No.", rec."Applies-to Doc. No.");
        if SalesInvoiceHeader.FindFirst() then
            OrderNo := SalesInvoiceHeader."Order No.";

        SalesShipmentHeader.SetRange("Order No.", OrderNo);
        if SalesShipmentHeader.FindFirst() then
            ShipmentNo := SalesShipmentHeader."No.";

    end;

    var
        OrderNo: Code[20];
        ShipmentNo: Code[20];
}
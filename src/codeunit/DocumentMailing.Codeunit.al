codeunit 70102 DocumentMailing
{
    trigger OnRun()
    begin

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Document-Mailing", 'OnBeforeEmailFileInternal', '', false, false)]
    local procedure MyProcedure(var TempEmailItem: Record "Email Item" temporary; var PostedDocNo: Code[20])
    var
        SalesHeader: Record "Sales Header";
        SalesPerson: Record "Salesperson/Purchaser";
        Customer: Record Customer;
    begin
        SalesHeader.SetRange("No.", PostedDocNo);
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        if SalesHeader.FindFirst() then begin
            if Customer.Get(SalesHeader."Sell-to Customer No.") then
                if SalesPerson.Get(Customer."Salesperson Code") then
                    TempEmailItem."Send CC" := SalesPerson."E-Mail";
        end;
    end;

    var
        myInt: Integer;
}
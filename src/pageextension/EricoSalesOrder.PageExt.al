pageextension 70105 EricoSalesOrder extends "Sales Order"
{
    layout
    {
        addafter(Status)
        {
            /*field("Due Exceed Status"; Rec."Due Exceed Status")
            {
                ApplicationArea = All;
                Caption = 'Due Exceed Approval Status';
                Editable = false;
            }*/
        }
    }

    actions
    {
        modify(SendApprovalRequest)
        {
            trigger OnAfterAction()
            var
                myInt: Integer;
            begin

            end;
        }
    }


    var
        NeedApproval: Boolean;
        Answer: Boolean;
}
pageextension 70106 EricoApprovalUserSetup extends "Approval User Setup"
{

    layout
    {
        addafter("Salespers./Purch. Code")
        {
            field("Overdue Approver"; Rec."Overdue Approver")
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }



    var
        myInt: Integer;
}
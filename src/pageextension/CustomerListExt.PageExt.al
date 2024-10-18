pageextension 70100 CustomerListExt extends "Customer List"
{
    layout
    {

    }

    actions
    {
        addafter("Sales Journal")
        {
            action(SendEmail)
            {
                ApplicationArea = all;
                Caption = 'Send Email 2';
                Image = View;
                trigger OnAction()
                var
                    cduEWBSendEmailAuto: Codeunit AutoSendCustomerStatement;
                begin
                    cduEWBSendEmailAuto.Run();
                end;

            }
        }
    }

    var
        myInt: Integer;
}
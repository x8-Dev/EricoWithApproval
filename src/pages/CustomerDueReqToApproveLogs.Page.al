page 70101 CustomerDueReqToApproveLogs
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    Caption = 'Customer Due - Request to Approve Logs';
    SourceTable = CustomerDueReqstToApprove;
    DeleteAllowed = false;
    ModifyAllowed = false;
    InsertAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                }
                field("Sender ID"; Rec."Sender ID")
                {
                    ApplicationArea = All;
                }
                field("Approved By"; Rec."Approved By")
                {
                    ApplicationArea = All;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                }
            }
        }
        area(Factboxes)
        {

        }
    }

    actions
    {
        area(Processing)
        {

        }
    }

    trigger OnFindRecord(Which: Text): Boolean
    var
        myInt: Integer;
    begin
        Rec.SetRange(Status, Rec.Status::Approved);
        EXIT(Rec.FInd(Which) AND CheckIfApprover());
    end;

    trigger OnNextRecord(Steps: Integer): Integer
    var
        NewStepCount: Integer;
    BEGIN
        REPEAT

            NewStepCount := Rec.Next(Steps);
        UNTIL (NewStepCount = 0) OR CheckIfApproverAndStatus();

        EXIT(NewStepCount);
    END;

    local procedure CheckIfApprover(): Boolean
    var
        UserSetup: Record "User Setup";
    begin
        if UserSetup.get(UserId) then begin
            if (UserSetup."Overdue Approver" = true) then
                exit(true);
        end;
    end;

    local procedure CheckIfApproverAndStatus(): Boolean
    var
        UserSetup: Record "User Setup";
    begin
        if UserSetup.get(UserId) then begin
            if (UserSetup."Overdue Approver" = true) and (rec.Status = rec.Status::Approved) then
                exit(true);
        end;
    end;
}

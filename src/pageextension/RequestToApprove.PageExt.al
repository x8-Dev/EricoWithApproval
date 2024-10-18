pageextension 70109 "RequestsToApproveExt" extends "Requests to Approve"
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        modify(Approve)
        {
            trigger OnBeforeAction()
            var
                SalesHeader: Record "Sales Header";
                ApprovalEntry: Record "Approval Entry";
                ApprovalsMgmt: Codeunit "Approvals Mgmt.";
            begin
                CurrPage.SetSelectionFilter(ApprovalEntry);
                SalesHeader.SetRange("No.", ApprovalEntry."Document No.");
                SalesHeader.SetRange("Due Exceed Status", SalesHeader."Due Exceed Status"::Pending);
                if SalesHeader.FindFirst() then begin
                    Error('The approval is still pending contact the Overdue Approver');
                end;
            end;
        }
    }

    var
        myInt: Integer;
}
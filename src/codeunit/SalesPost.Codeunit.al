codeunit 70104 SalesPost
{
    trigger OnRun()
    begin

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnBeforeCheckSalesApprovalPossible', '', false, false)]
    local procedure OnBeforeCheckSalesApprovalPossible(var IsHandled: Boolean; var Result: Boolean; var SalesHeader: Record "Sales Header")
    var
        CustomerLedgerEntries: Record "Cust. Ledger Entry";
        NoofDays: Integer;
        WithBalanceDue: Boolean;
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        NoWorkflowEnabledErr: Label 'No approval workflow for this record type is enabled.';
        NothingToApproveErr: Label 'There is nothing to approve.';
    begin
        IsHandled := true;

        if not ApprovalsMgmt.IsSalesApprovalsWorkflowEnabled(SalesHeader) then
            Error(NoWorkflowEnabledErr);

        if not SalesHeader.SalesLinesExist() then
            Error(NothingToApproveErr);

        CustomerLedgerEntries.SetRange(Open, true);
        CustomerLedgerEntries.SetRange("Customer No.", SalesHeader."Sell-to Customer No.");
        if CustomerLedgerEntries.FindFirst() then begin
            repeat
                if SalesHeader."Due Exceed Status" = SalesHeader."Due Exceed Status"::Pending then begin
                    Error('The approval is still pending contact the Overdue Approver');
                end else if SalesHeader."Due Exceed Status" = SalesHeader."Due Exceed Status"::Rejected then begin
                    Error('The approval is still rejected contact the Overdue Approver');
                end;
                if SalesHeader."Due Exceed Status" = SalesHeader."Due Exceed Status"::" " then begin
                    NoofDays := Today - CustomerLedgerEntries."Due Date";
                    if NoofDays > 10 then begin
                        Answer := Dialog.Confirm('This customers has an overdue invoice past 10 days. An approval is required for this Sales Order. Do you want to proceed?');
                        if Answer = false then begin
                            //IsHandled := true;
                            result := false;
                            Exit;
                        end else begin
                            SendCustomerDueReqToApprove(SalesHeader);
                            SalesHeader."Due Exceed Status" := SalesHeader."Due Exceed Status"::Pending;
                            SalesHeader.Modify();
                            Result := true;
                            //IsHandled := false;
                            SendEmail(CustomerLedgerEntries."Customer No.", SalesHeader."No.");
                            exit;
                        end;
                        WithBalanceDue := false;
                    end;
                end;
            until CustomerLedgerEntries.Next = 0;

            /* if WithBalanceDue = false then
                 IsHandled := false;

             if SalesHeader."Due Exceed Status" = SalesHeader."Due Exceed Status"::Approved then
                 IsHandled := false;*/
        end;

    end;

    procedure SendCustomerDueReqToApprove(SalesHeader: Record "Sales Header")
    var
        DuetoApprove: Record CustomerDueReqstToApprove;
        UserSetup: Record "User Setup";
        ApproverIDs: Text;
    begin
        DuetoApprove.Init();
        DuetoApprove."Document No." := SalesHeader."No.";
        DuetoApprove."Customer No." := SalesHeader."Sell-to Customer No.";
        DuetoApprove."Sender ID" := UserId;
        DuetoApprove.Status := DuetoApprove.Status::New;
        DuetoApprove.Insert();
    end;

    procedure SendEmail(var Customer: Code[20]; var SONo: Code[20])
    var
        EmailMessage: Codeunit "Email Message";
        Email: Codeunit Email;
        TxtDefaultCCMailList: List of [Text];
        TxtDefaultBCMailList: List of [Text];
        TxtRecipientsMailList: List of [Text];
        AttachmentTempBlob: Codeunit "Temp Blob";
        AttachmentIntStream: InStream;
        AttachmentOutStream: OutStream;
        SalesNReceivablesSetup: Record "Sales & Receivables Setup";
        UserSetup: Record "User Setup";
        Body: Label 'Hi,<br><br>%1 is created for Customer No. %2. This customer has an overdue invoice that is past 10 days, please approve before the SO can be posted. <br><br><a href="https://businesscentral.dynamics.com/f1db0df1-49ef-4fea-9324-d8843ba78d96/%3?company=%4&page=70100&dc=0">Requests to approve</a>';
        EnvironmentInfo: Codeunit "Environment Information";
        CompanyInfo: Record "Company Information";
    begin
        UserSetup.SetRange("Overdue Approver", true);
        if UserSetup.FindFirst() then begin
            repeat
                TmpRecipients := DelChr(UserSetup."E-Mail", '<>', ';');
                TmpRecipients := TmpRecipients + ';';
                while StrPos(TmpRecipients, ';') > 1 do begin
                    TmpRecipient := Delchr(CopyStr(TmpRecipients, 1, StrPos(TmpRecipients, ';') - 1), '<>', ';');
                    TmpRecipients := CopyStr(TmpRecipients, StrPos(TmpRecipients, ';') + 1);
                    TxtRecipientsMailList.Add(TmpRecipient);
                end;
            until UserSetup.next = 0;
        end;

        //TxtDefaultBCMailList.Add(Vendor.BCC);

        //CountSubStrings(Vendor.BCC, ',');
        //TxtDefaultCCMailList.Add(Vendor.CC);

        CompanyInfo.Get();

        EmailMessage.Create(
            TxtRecipientsMailList,
            'Sales Order for Approval',
            STRSUBSTNO(Body, SONo, Customer, EnvironmentInfo.GetEnvironmentName(), CompanyInfo.Name),
            true,
            TxtDefaultCCMailList,
            TxtDefaultBCMailList
        );

        Email.Send(EmailMessage, Enum::"Email Scenario"::Default);
    end;

    var
        Answer: Boolean;
        TmpRecipients: Text;
        TmpRecipient: Text;
}
﻿codeunit 70009215 "O4N GL SN Assisted Setup"
{

    trigger OnRun();
    begin
    end;

    var
        Setup: Record "O4N GL SN Setup";
        HelpResource: Record "O4N GL SN Help Resource";
        GLSourceNamesTxt: Label 'Set up G/L Source Names';
        RequiredPermissionMissingErr: Label 'You have not been granted required access rights to start the Assisted Setup.\\The Assisted Setup for G/L Source Names is about assigning the required permissions to users.  To be able to assign permissions you need to be granted either the SUPER og SECURITY permission set.';

    procedure VerifyUserAccess();
    var
        AccessControl: Record "Access Control";
    begin
        with AccessControl do begin
            SETRANGE("User Security ID", USERSECURITYID());
            SETFILTER("Role ID", '%1|%2', 'SUPER', 'SECURITY');
            if ISEMPTY then
                ERROR(RequiredPermissionMissingErr);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Assisted Setup", 'OnRegister', '', true, false)]
    local procedure OnRegisterAssistedSetup();
    begin
        if not Setup.WRITEPERMISSION then exit;
        if not HelpResource.WRITEPERMISSION then exit;
        InitializeSetup();
        AddToAssistedSetup();
    end;

    local procedure InitializeSetup();
    begin
        with Setup do
            if not Get() then begin
                INIT();
                INSERT();
            end;

        with HelpResource do
            InitializeResources();
    end;

    local procedure AddToAssistedSetup();
    var
        HelpResources: Record "O4N GL SN Help Resource";
        AssistedSetup: Codeunit "Assisted Setup";
        AppMgt: Codeunit "O4N GL SN App Mgt.";
        AssistedSetupGroup: Enum "Assisted Setup Group";
        VideoCategory: Enum "Video Category";
        AboutTxt: Label 'Add the Source Name field to G/L Entries and a direct link to the source entity card.';
    begin
        Setup.GET();
        if not HelpResources.Get(HelpResources.GetSetupVideoCode()) then
            HelpResources.InitializeResources();
        HelpResources.Get(HelpResources.GetSetupVideoCode());
        AssistedSetup.Add(AppMgt.GetAppId(), PAGE::"O4N GL SN Setup Wizard", GLSourceNamesTxt, AssistedSetupGroup::Extensions, HelpResources.Url, VideoCategory::FinancialReporting, '', AboutTxt);
        if Setup.Status = Setup.Status::Completed then
            AssistedSetup.Complete(PAGE::"O4N GL SN Setup Wizard");
    end;
}



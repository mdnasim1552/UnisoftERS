<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Templates/ProcedureMaster.Master" CodeBehind="PatientNotes.aspx.vb" Inherits="UnisoftERS.PatientNotes" %>
<asp:Content ID="Content1" ContentPlaceHolderID="pHeadContentPlaceHolder" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="pBodyContentPlaceHolder" runat="server">
    <div class="otherDataHeading">
        <b>Patient Notes</b>
    </div>
    <fieldset class="patientNotesFieldSet" style="width:510px">
        <legend>Patient Notes</legend>
        <telerik:RadTextBox Width="500px" Height="100px" MaxLength="5000" TextMode="MultiLine" ID="PatientNotesTextBox" runat="server" Skin="Windows7" />
    </fieldset>
    <br />
    <fieldset class="patientHistoryFieldSet" style="width:510px">
        <legend>Patient History</legend>
        <telerik:RadTextBox Width="500px" Height="100px" MaxLength="5000" TextMode="MultiLine" ID="PatientHistoryTextBox" runat="server" Skin="Windows7" />
    </fieldset>
    <br />
    <div style="height: 10px; margin-left: 10px; padding-top:2px; padding-bottom:2px">
        <telerik:RadButton ID="SaveButton" runat="server" Text="Save & Close" Skin="Metro" Icon-PrimaryIconCssClass="telerikSaveButton"/>
        <telerik:RadButton ID="CancelButton" runat="server" Text="Cancel" Skin="Metro" Icon-PrimaryIconCssClass="telerikCancelButton" />
    </div>
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="LeftPaneContentPlaceHolder" runat="server">
</asp:Content>

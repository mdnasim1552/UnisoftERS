<%@ Control Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.UserControls_AppointmentForm" Codebehind="AppointmentForm.ascx.vb" %>

<div class="rsAdvancedEdit rsAdvancedModal" style="position: relative;">
    <div class="rsModalBgTopLeft">
    </div>
    <div class="rsModalBgTopRight">
    </div>
    <div class="rsModalBgBottomLeft">
    </div>
    <div class="rsModalBgBottomRight">
    </div>
    <div class="rsAdvTitle">
        <h1 class="rsAdvInnerTitle">New Appointment</h1>
        <asp:LinkButton runat="server" ID="AdvancedEditCloseButton" CssClass="rsAdvEditClose"
            CommandName="Cancel" CausesValidation="false" ToolTip='Close'>Close</asp:LinkButton>
    </div>
    <div class="rsAdvContentWrapper">
        <table style="margin-left: 20px;">
            <tr>
                <td style="width: 150px;">
                    <asp:Label AssociatedControlID="ProcTypeComboBox" runat="server" CssClass="inline-label">ProcedureType:</asp:Label>
                </td>
                <td>
                    <telerik:RadComboBox ID="ProcTypeComboBox" runat="server" Skin="Windows7" Width="130">
                        <Items>
                            <telerik:RadComboBoxItem Text="" Value="" />
                            <telerik:RadComboBoxItem Text="Upper GI" Value="1" />
                            <telerik:RadComboBoxItem Text="ERCP" Value="2" />
                            <telerik:RadComboBoxItem Text="Colonoscopy" Value="3" />
                        </Items>
                    </telerik:RadComboBox>
                </td>
            </tr>
            <tr>
                <td>
                    <asp:Label AssociatedControlID="PatientNoTextBox" runat="server" CssClass="inline-label">Patient No:</asp:Label>
                </td>
                <td>
                    <telerik:RadTextBox ID="PatientNoTextBox" runat="server" Skin="Windows7" Width="130"></telerik:RadTextBox>
                </td>
            </tr>
            <tr>
                <td>
                    <asp:Label AssociatedControlID="RoomComboBox" runat="server" CssClass="inline-label">Room:</asp:Label>
                </td>
                <td>
                    <telerik:RadComboBox ID="RoomComboBox" runat="server" Skin="Windows7" Width="100">
                        <Items>
                            <telerik:RadComboBoxItem Text="" Value="" />
                            <telerik:RadComboBoxItem Text="Endo Room 1" Value="Endo Room 1" />
                            <telerik:RadComboBoxItem Text="Endo Room 2" Value="Endo Room 2" />
                            <telerik:RadComboBoxItem Text="Endo Room 3" Value="Endo Room 3" />
                            <telerik:RadComboBoxItem Text="X-Ray" Value="X-Ray" />
                        </Items>
                    </telerik:RadComboBox>
                </td>
            </tr>
            <tr>
                <td>
                    <asp:Label AssociatedControlID="StartDatePicker" runat="server" CssClass="inline-label">Start time:</asp:Label>
                </td>
                <td>
                    <telerik:RadDatePicker runat="server" ID="StartDatePicker" CssClass="rsAdvDatePicker" Width="100px" MinDate="1900-01-01" Skin="Windows7">
                        <DateInput ID="DateInput2" runat="server" />
                    </telerik:RadDatePicker>
                    <telerik:RadTimePicker runat="server" ID="StartTimePicker" CssClass="rsAdvTimePicker" Width="70px" Skin="Windows7">
                        <DateInput ID="DateInput3" runat="server" />
                        <TimeView ID="TimeView1" runat="server" Columns="2" ShowHeader="false" StartTime="08:00"
                            EndTime="18:00" Interval="00:30" />
                    </telerik:RadTimePicker>
                </td>
            </tr>
            <tr>
                <td>
                    <asp:Label AssociatedControlID="EndDatePicker" runat="server" CssClass="inline-label">End Time:</asp:Label>
                </td>
                <td>
                    <telerik:RadDatePicker runat="server" ID="EndDatePicker" CssClass="rsAdvDatePicker" Width="100px" MinDate="1900-01-01" Skin="Windows7">
                        <DateInput ID="DateInput1" runat="server" />
                    </telerik:RadDatePicker>
                    <telerik:RadTimePicker runat="server" ID="EndTimePicker" CssClass="rsAdvTimePicker" Width="70px" Skin="Windows7">
                        <DateInput ID="DateInput4" runat="server" />
                        <TimeView ID="TimeView2" runat="server" Columns="2" ShowHeader="false" StartTime="08:00"
                            EndTime="18:00" Interval="00:30" />
                    </telerik:RadTimePicker>
                </td>
            </tr>
        </table>
        <asp:Panel runat="server" ID="Panel1" CssClass="rsAdvancedSubmitArea">
            <div class="rsAdvButtonWrapper">
                <asp:LinkButton CommandName="Update" runat="server" ID="LinkButton1" CssClass="rsAdvEditSave">Save</asp:LinkButton>
                <asp:LinkButton runat="server" ID="LinkButton2" CssClass="rsAdvEditCancel" CommandName="Cancel" CausesValidation="false">Cancel</asp:LinkButton>
            </div>
        </asp:Panel>
    </div>
</div>

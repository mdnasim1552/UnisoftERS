<%@ Page Language="vb" MasterPageFile="~/Templates/scheduler.master" AutoEventWireup="false" CodeBehind="AddAdditionalDocument.aspx.vb" Inherits="UnisoftERS.AddAdditionalDocument" %>

<asp:Content ID="MainBodyContent" ContentPlaceHolderID="BodyContentPlaceHolder" runat="Server">

    <telerik:RadScriptBlock ID="RadScriptBlock1" runat="server">
        <script type="text/javascript">
            function ShowMessage() {

                alert("Please choose Hospital , File and Procedure Type or Therapeutic Type ");
            }

            function CheckFileType(sender, args) {
                var allowedMimeTypes = $telerik.$(sender.get_element()).attr("data-clientFilter");
                $telerik.$(args.get_row()).find(".ruFileInput").attr("accept", allowedMimeTypes);
            }
        </script>
    </telerik:RadScriptBlock>
    <div id="ContentDiv" style="font-size:small">
           <telerik:RadNotification ID="LetterPrintRadNotification" runat="server" VisibleOnPageLoad="false" Height="170px" CssClass="rad-window-popup" ShowCloseButton="true" Skin="Metro" Title="Booking error" AutoCloseDelay="0" />


        <fieldset style="position:relative; width: 650px; height: 165px">
            <asp:HiddenField runat="server" ID="hdnAdditionalDocumentId" />
            <table id="tableAdditionalAdd" style="width: 650px;">

                <tr>
                    <td >Hospital Name :</td>
                    <td>
                        <telerik:RadDropDownList ID="HospitalDropDownList" CssClass="filterDDL" runat="server" Width="150" DataTextField="HospitalName" AutoPostBack="true" DataValueField="OperatingHospitalID" OnSelectedIndexChanged="HospitalDropDownList_SelectedIndexChanged" />
                    </td>


                </tr>
                
                 <tr >
                     
                    <td>Procedure Name :</td>
                    <td>
                        <telerik:RadDropDownList ID="ProcedureNameDropdown" CssClass="filterDDL" runat="server" Width="150" DataTextField="ProcedureType" AutoPostBack="true" DataValueField="ProcedureTypeId" OnSelectedIndexChanged="ProcedureNameDropdown_SelectedIndexChanged" />
                    </td>

                    <td>Combined Procedure Name :</td>
                    <td>
                        <telerik:RadDropDownList ID="CombindProcedureNameDropdown" CssClass="filterDDL" runat="server" Width="150" DataTextField="ProcedureType" AutoPostBack="true" DataValueField="ProcedureTypeId"  />
                    </td>
                </tr>
                <tr>
                    
                    <td>Therapeutic Type:</td>
                    <td>
                        <telerik:RadDropDownList ID="TherapeuticTypeDropdown" CssClass="filterDDL" runat="server" Width="150" DataTextField="Description" AutoPostBack="true" DataValueField="Id" />
                    </td>
                </tr>
                <tr>
                    <td>Document Name :</td>
                    <td>
                        <telerik:RadTextBox ID="DocumentName" CssClass="filterDDL" runat="server" Width="150" AutoPostBack="true" />
                    </td>
                </tr>
                <tr>
                    <td>File :</td>
                    <td colspan="3">
                        <telerik:RadAsyncUpload runat="server" ID ="RadAsyncUploadAdditionDocument"
                            Skin="Metro"  
                            RenderMode="Lightweight"
                            TemporaryFolder="~\App_Data\WorkDirectory\RadUploadTemp\"
                            AllowedFileExtensions="pdf"
                            data-clientFilter=".pdf"
                            OnClientAdded="CheckFileType"
                            AutoAddFileInputs="true">
                        </telerik:RadAsyncUpload>
                    </td>
                </tr>

                <tr>
                    <td colspan="2"></td>
                </tr>

            </table>
            <div style="text-align: right; position:absolute; bottom:0; right:0; margin:0 5px 5px 0;">
                <telerik:RadButton Skin="Metro" ID="SaveFile" runat="server" Text="Save" OnClick="SaveButton_Click" Icon-PrimaryIconUrl="../../Images/icons/save.png">
                   
                </telerik:RadButton>
                <telerik:RadButton Skin="Metro" ID="Cancel" runat="server" Text="Cancel" OnClick="CancelButton_Click" Icon-PrimaryIconUrl="../../Images/icons/cancel.png">
                    
                </telerik:RadButton>
            </div>

        </fieldset>
    </div>
</asp:Content>

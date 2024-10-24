<%@ Page Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.Products_Options_EditDiagnoses" Codebehind="EditDiagnoses.aspx.vb" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Diagnoses form</title>
    <telerik:RadStyleSheetManager ID="RadStyleSheetManager1" runat="server" />
    <script type="text/javascript" src="../../Scripts/Global.js"></script>
    <script type="text/javascript" src="../../Scripts/jquery-3.6.3.min.js"></script>
    <link type="text/css" href="../../Styles/Site.css" rel="stylesheet" />
    <style type="text/css">        
    </style>

    <telerik:RadScriptBlock ID="RadScriptBlock1" runat="server">
        <script type="text/javascript">
            $(window).on('load', function () {
            });

            $(document).ready(function () {
            });



            function CloseAndRebind(args) {
                GetRadWindow().BrowserWindow.refreshGrid(args);
                GetRadWindow().close();
            }

            function GetRadWindow() {
                var oWindow = null;
                if (window.radWindow) oWindow = window.radWindow; //Will work in Moz in all cases, including clasic dialog
                else if (window.frameElement.radWindow) oWindow = window.frameElement.radWindow; //IE (and Moz as well)

                return oWindow;
            }
            function CancelEdit() {
                GetRadWindow().BrowserWindow.refreshGrid();
                GetRadWindow().close();
            }

        </script>
    </telerik:RadScriptBlock>
</head>

<body>
    <script type="text/javascript">
    </script>
    <form id="form1" runat="server">
        <telerik:RadScriptManager ID="RadScriptManager1" runat="server" />
        <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Web20" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />

        <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server">
            <AjaxSettings>
                <telerik:AjaxSetting AjaxControlID="SaveAndCloseButton">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="RadNotification1" />
                        <telerik:AjaxUpdatedControl ControlID="DiagDetailsFormView" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
                           </AjaxSettings>
        </telerik:RadAjaxManager>

        <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Metro">
        </telerik:RadAjaxLoadingPanel>

        <div class="optionsHeading">
            <asp:Label ID="HeadingLabel" runat="server" Text="Edit User"></asp:Label>
        </div>

        <telerik:RadFormDecorator ID="UserMaintenanceRadFormDecorator" runat="server" DecoratedControls="All"
            DecorationZoneID="FormDiv" Skin="Web20" />
        <asp:ObjectDataSource ID="DiagObjectDataSource" runat="server" TypeName="UnisoftERS.OtherData" SelectMethod="DiagnoseSelect" UpdateMethod="DiagnoseUpdate" InsertMethod="DiagnoseInsert">
            <SelectParameters>
                  <asp:Parameter Name="DiagnosesMatrixID" Type="Int32" />
                </SelectParameters>
            <UpdateParameters>
                <asp:Parameter Name="DiagnosesMatrixID" Type="Int32" />
                <asp:Parameter Name="DisplayName" Type="String" />
                <asp:Parameter Name="EndoCode" Type="String" ConvertEmptyStringToNull="true" />
                <asp:Parameter Name="Disabled" Type="Boolean" />
                <asp:Parameter Name="OrderByNumber" Type="Int32" />
                <asp:Parameter Name="ProcedureTypeID" Type="Int32" />
                <asp:Parameter Name="Section" Type="String" />
            </UpdateParameters>
            <InsertParameters> 
                <asp:Parameter Name="DiagnosesMatrixID" Type="Int32"/>            
                <asp:Parameter Name="DisplayName" Type="String" />
                <asp:Parameter Name="EndoCode" Type="String" ConvertEmptyStringToNull="true" />
                <asp:Parameter Name="Disabled" Type="Boolean" />
                <asp:Parameter Name="OrderByNumber" Type="Int32" />
                  <asp:Parameter Name="ProcedureTypeID" Type="Int32" />
                <asp:Parameter Name="Section" Type="String" />
           </InsertParameters>
        </asp:ObjectDataSource>       
        <div id="FormDiv" runat="server">
            <div style="margin-left: 10px;" class="rptText">
                <asp:FormView ID="DiagDetailsFormView" runat="server" DataSourceID="DiagObjectDataSource" BorderStyle="None">
                    <EditItemTemplate>
                        <fieldset class="rdfFieldset rdfBorders" style="padding:15px; width:315px;">
                            <asp:HiddenField runat="server" ID="idhidden" Value ='<%# Bind("DiagnosesMatrixID")%>' />
                           
                                    <div class="rdfRow" style="padding-bottom:5px;">
                                        <asp:Label runat="server" ID="Label1" Text="Procedure Type:" Width="100px"></asp:Label>
                                        <asp:textbox Text='<%# Bind("ProcedureTypeID")%>' runat="server" ID="SectionTextbox"  Enabled="false"/>
                                    </div>
                                    <div class="rdfRow" style="padding-bottom:5px;">
                                        <asp:Label runat="server" ID="Label2" Text="Section:" Width="100px"></asp:Label>
                                        <asp:textbox Text='<%# Bind("Section")%>' runat="server" ID="LocationTextbox" Enabled="false" />
                                    </div>
                                    <div class="rdfRow"  style="padding-bottom:5px;">
                                        <asp:Label runat="server" ID="Lbl1" Text="Name:" Width="100px"></asp:Label>
                                        <asp:textbox Text='<%# Bind("DisplayName")%>' runat="server" ID="lbl2" />
                                    </div>
                                    <div class="rdfRow"  style="padding-bottom:5px;">
                                        <asp:Label runat="server" ID="lbl3" Text="Endoscopy Code:" Width="100px"></asp:Label>
                                       <asp:textbox Text='<%# Bind("EndoCode")%>' runat="server" ID="lbl4" />
                                    </div>
                                    <div class="rdfRow"  style="padding-bottom:5px;">
                                        <asp:Label runat="server" ID="lbl5" Text="Disabled:" Width="100px"></asp:Label>
                                        <asp:CheckBox ID="disabledcheckbox" runat="server" Checked='<%# Bind("Disabled")%>' />
                                      </div>
                                    <div class="rdfRow">
                                        <asp:Label runat="server" ID="lbl7" Text="Order By Number:" Width="100px"></asp:Label>
                                      <telerik:RadNumericTextBox ID="ordertxt" runat="server"
                                                IncrementSettings-InterceptMouseWheel="false"
                                                IncrementSettings-Step="1"
                                                Width="45px" DbValue='<%# Bind("OrderByNumber")%>'
                                                MinValue="0" Culture="en-GB" DbValueFactor="1" LabelWidth="20px" Value="0">
                                                <NumberFormat DecimalDigits="0" />
                                            </telerik:RadNumericTextBox>
                                       
                                    </div>                                    
                                </fieldset>
                        
                       
                        <div id="buttonsdiv" style="height: 10px; margin-left: 5px;  vertical-align: central;padding-top:15px;  ">
                            <%--<telerik:RadButton ID="SaveButton" runat="server" Text="Save" Skin="Web20" AutoPostBack="true" />--%>
                            <telerik:RadButton ID="SaveAndCloseButton" runat="server" Text="Save & Close" Skin="Web20" AutoPostBack="true" Icon-PrimaryIconCssClass="telerikSaveButton" />
                            <telerik:RadButton ID="CancelButton" runat="server" Text="Cancel" Skin="Web20" AutoPostBack="false" OnClientClicked="CancelEdit" Icon-PrimaryIconCssClass="telerikCancelButton"
                                CausesValidation="false" />
                        </div>
                    </EditItemTemplate>
                </asp:FormView>
            </div>
            
        </div>
    </form>
</body>
</html>

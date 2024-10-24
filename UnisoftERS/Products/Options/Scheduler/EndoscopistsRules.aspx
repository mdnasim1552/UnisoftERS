<%@ Page Language="vb" MasterPageFile="~/Templates/Scheduler.master" AutoEventWireup="false" CodeBehind="EndoscopistsRules.aspx.vb" Inherits="UnisoftERS.products_options_scheduler_EndoscopistsRules" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContentPlaceHolder" runat="Server">
    <title>Set Endocopists Rules</title>
    <script type="text/javascript" src="../../../Scripts/Global.js"></script>
    <script type="text/javascript" src="../../../Scripts/jquery-3.6.3.min.js"></script>
    <link type="text/css" href="../../../Styles/Site.css" rel="stylesheet" />
    <style type="text/css">
        .auto-style1 {
            width: 292px;
        }

        .auto-style2 {
            width: 436px;
        }

        .auto-style3 {
            width: 510px;
        }
    </style>

    <telerik:RadScriptBlock ID="RadScriptBlock1" runat="server">
        <script type="text/javascript">
            $(window).on('load', function () {
                bindEvents();
            });

            function bindEvents() {
                $('[data-check-type] input[type=checkbox]').on('click', function () {
                    
                    var type = $(this).closest('span').attr('data-check-type');
                    var therapeuticChecked = false;
                    //toggle checkbox groups
                    if (type.toLowerCase() == 'therapeutic') {
                        therapeuticChecked = $(this).is(":checked")
                        $(this).closest('tr').find('.define-button').attr("disabled", (therapeuticChecked == false));
                        $(this).closest('tr').find('.define-button').attr("enabled", (therapeuticChecked == true));
                    }

                });

                $('.define-button').on('click', function () {

                    var procedureType = $(this).attr("data-proc-type");
                    var procedureTypeID = $(this).attr("data-proc-id");
                    var width = "", height = "";
                    switch (procedureType) {
                        case "OGD": {
                            width = '450px';
                            height = '620px';
                            break;
                        }

                        case "ERCP": {
                            width = '450px';
                            height = '450px';
                            break;
                        }

                        case "COL": {
                            width = '400px';
                            height = '370px';
                            break;
                        }

                        case "SIG": {
                            width = '400px';
                            height = '370px';
                            break;
                        }

                        case "PROCT": {
                            width = '400px';
                            height = '370px';
                            break;
                        }

                        case "EUS": {
                            width = '450px';
                            height = '620px';
                            break;
                        }

                        case "EUS HPB": {
                            width = '450px';
                            height = '450px';
                            break;
                        }

                    }

                    var own = radopen("TherapeuticTypes.aspx?ProcedureType=" + procedureType + "&ProcedureTypeID=" + procedureTypeID, "Define " + procedureType + " therapeutic procedures", 450, 620);
                    own.set_visibleStatusbar(false);
                    return false;
                });
            }

            var pageUpdated;

            function procedure_changed() {
                 $.ajax({
                    type: "POST",
                    url: "EndoscopistsRules.aspx/SetPageUpdated",
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (data) {
                    },
                    error: function (jqXHR, textStatus, data) {
                    }
                });
            }

            $(document).ready(function () {
                Sys.Application.add_load(function () {
                    bindEvents(); //event handlers in here

                });

            });

        </script>

    </telerik:RadScriptBlock>
</asp:Content>
<asp:Content ID="BodyContent" ContentPlaceHolderID="BodyContentPlaceHolder" runat="Server">
    <asp:HiddenField ID="hiddenItemId" runat="server" />
    <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Metro" />
    <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" Position="Center" />

    <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Metro">
    </telerik:RadAjaxLoadingPanel>

    <telerik:RadWindowManager ID="RadWindowManager2" runat="server" Skin="Metro" Modal="true">
        <Windows>
            <telerik:RadWindow ID="TherapeuticTypes" runat="server" Title=""
                ReloadOnShow="false" ShowContentDuringLoad="false"
                Modal="true" KeepInScreenBounds="true" VisibleStatusbar="false" Skin="Metro">
            </telerik:RadWindow>
        </Windows>
    </telerik:RadWindowManager>

    <div class="optionsHeading">
        <asp:Label ID="HeadingLabel" runat="server" Text="Set Endoscopist Rules"></asp:Label>
    </div>



    <asp:ObjectDataSource ID="ProcedureTypesObjectDataSource" runat="server" SelectMethod="GetProcedureTypes" TypeName="UnisoftERS.DataAccess_Sch">
        <SelectParameters>
            <asp:Parameter Name="isGI" Type="Boolean" DefaultValue="true" />
        </SelectParameters>
    </asp:ObjectDataSource>

    <asp:ObjectDataSource ID="ConsultantEndoscopistObjectDataSource" runat="server" SelectMethod="GetConsultantEndoscopists" TypeName="UnisoftERS.DataAccess_Sch"></asp:ObjectDataSource>
    <div id="FormDiv" runat="server">

        <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Width="900px" Orientation="Horizontal" BorderSize="0" PanesBorderSize="0">
            <telerik:RadPane ID="ControlsRadPane" runat="server" Height="580px" Width="90%">

                <table id="ControlsTable" runat="server" class="optionsBodyText" style="margin-top: 5px; margin-left: 5px;" width="95%" cellpadding="0" cellspacing="0">
                    <tr>
                        <td class="auto-style1">
                            <fieldset class="otherDataFieldset">
                                <table style="width: 95%;">
                                    <tr>
                                        <td colspan="2">
                                            <div class="optionsBodyText">
                                                <asp:Panel ID="Panel3" runat="server" Skin="Metro" GroupingText="Please Note">
                                                    <table style="padding-left: 10px;">
                                                        <tr>
                                                            <td style="padding-top: 10px; padding-left: 10px; width: 10%;"></td>
                                                            <td style="padding-top: 10px; width: 100%;">
                                                                <asp:Label runat="server" ID="Label1">Use this screen window to build up the rules for the Endoscopist.
                                                                </asp:Label>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </asp:Panel>
                                            </div>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td valign="top">
                                            <fieldset>
                                                <table>
                                                    <tr>
                                                        <td>
                                                            <telerik:RadComboBox ID="ConsultantComboBox" CssClass="filterDDL" Filter="StartsWith" runat="server" DataTextField="EndoName" DataValueField="UserID" ZIndex="9501" Width="280px" Skin="Metro" AutoPostBack="True" OnSelectedIndexChanged="ConsultantComboBox_SelectedIndexChanged" />
                                                        </td>
                                                    </tr>
                                                </table>
                                            </fieldset>
                                        </td>
                                        <td>
                                            <fieldset style="">
                                                <table>
                                                    <tr align="center">
                                                        <td>
                                                            <asp:Repeater ID="rptProcedureTypes" runat="server" DataSourceID="ProcedureTypesObjectDataSource" OnItemDataBound="rptProcedureTypes_ItemDataBound">
                                                                <HeaderTemplate>
                                                                    <table cellpadding="4">
                                                                        <tr>
                                                                            <td>Diagnostic</td>
                                                                            <td>Therapeutic</td>
                                                                            <td></td>
                                                                        </tr>
                                                                </HeaderTemplate>
                                                                <ItemTemplate>
                                                                    <tr>
                                                                        <td>
                                                                            <asp:HiddenField ID="ProcedureTypeHiddenField" runat="server" Value='<%#Eval("SchedulerProcName") %>' />
                                                                            <asp:HiddenField ID="ProcedureTypeIDHiddenField" runat="server" Value='<%#Eval("ProcedureTypeID") %>' />
                                                                            <asp:CheckBox ID="DiagnosticProcedureTypesCheckBox" runat="server" Text='<%#Eval("SchedulerProcName") %>' data-check-type="diagnostic" GroupName="procedure-group" />
                                                                        </td>
                                                                        <td>
                                                                            <asp:CheckBox ID="TherapeuticProcedureTypesCheckBox" runat="server" data-val-id='<%#Eval("ProcedureTypeID") %>' Text='<%#Eval("SchedulerProcName") %>' data-check-type="therapeutic" GroupName="procedure-group" />
                                                                        </td>
                                                                        <td>
                                                                            <asp:Button ID="DefineTherapeuticProcedureButton" runat="server" data-val-id='<%#Eval("ProcedureTypeID") %>' Text="Define" Enabled="true" CssClass="define-button" data-proc-type='<%#Eval("SchedulerProcName") %>' data-proc-id='<%#Eval("ProcedureTypeID") %>' />
                                                                        </td>
                                                                    </tr>
                                                                </ItemTemplate>
                                                                <FooterTemplate>
                                                                    </table>
                                                                </FooterTemplate>
                                                            </asp:Repeater>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </fieldset>
                                        </td>
                                    </tr>
                                </table>
                            </fieldset>
                        </td>
                        <td></td>
                    </tr>
                </table>
                <div>
                    <table>
                        <tr>
                            <td>
                                <telerik:RadButton ID="SaveRadButton" runat="server" Text="Save" AutoPostBack="True" OnClick="SaveRadButton_Click" />
                            </td>

                            <td>
                                <telerik:RadButton ID="CancelRadButton" runat="server" Text="Cancel" AutoPostBack="True" OnClick="CancelRadButton_Click" />
                            </td>
                        </tr>
                    </table>
                </div>
            </telerik:RadPane>
        </telerik:RadSplitter>
    </div>
</asp:Content>

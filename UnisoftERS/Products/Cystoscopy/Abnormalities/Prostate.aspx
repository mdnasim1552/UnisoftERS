<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="Prostate.aspx.vb" Inherits="UnisoftERS.Prostate" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <script type="text/javascript" src="../../../Scripts/jquery-3.6.3.min.js"></script>
    <script src="../../../Scripts/global.js"></script>
    <link type="text/css" href="../../../Styles/Site.css" rel="stylesheet" />
    <link type="text/css" href="../../../Styles/Site.css" rel="stylesheet" />
    <telerik:RadScriptBlock runat="server" ID="RadCodeBlock">
        <script type="text/javascript">
            var prostateChanged = false;
            $(window).on('load', function () {
           
               
            })
            function CloseWindow() {
                window.parent.CloseWindow();
            }

            $(document).ready(function () {
                $("#CystoscopyProstateFormView_NoneCheckBox").change(function () {
                  
                    ToggleNoneCheckBox($(this).is(":checked"))
                    valueChanged();
                })

                //changed by mostafiz issue 3647
                $("#CystoscopyProstateFormView_ProstateTable tr td:first-child input").change(function () {
                    if ($(this).is(":checked")) {
                        $("#CystoscopyProstateFormView_NoneCheckBox").prop("checked", false);
                        valueChanged();
                    }
                   
                })
                $(window).on('beforeunload', function () {
                    if (prostateChanged) $('#<%=SaveButton.ClientID%>').click();
                });
                $(window).on('unload', function () {
                    localStorage.clear();
                    setRehideSummary();
                });
            })

            function valueChanged() {
                prostateChanged = true;
                var valueToSave = false;
                $("#CystoscopyProstateFormView_ProstateTable tr td:first-child").each(function () {
                    if ($(this).find("input:checkbox").is(':checked')) valueToSave = true;
                });
                if (!$('#CystoscopyProstateFormView_NoneCheckBox').is(':checked') && !valueToSave)
                    localStorage.setItem('valueChanged', 'false');
                else
                    localStorage.setItem('valueChanged', 'true');

            }

        
            //changed by mostafiz issue 3647
            function ToggleNoneCheckBox(checked) {

                if (checked) {
                    $("#CystoscopyProstateFormView_ProstateTable tr td:first-child").each(function () {
                        $(this).find("input:checkbox:checked").prop("checked", false);
                        $(this).find("input:checkbox").trigger("change");

                    })
                }
                else {
                    $("#CystoscopyProstateFormView_ProstateTable tr td:first-child").each(function () {
                        $(this).find("input:checkbox").trigger("change");
                    })

                }
            }


        </script>
    </telerik:RadScriptBlock>
</head>
<body>
    <form id="form1" runat="server">
        <asp:HiddenField ID="RegionHidden" runat="server" />
        <telerik:RadFormDecorator ID="RadFormDecorator2" runat="server" DecoratedControls="All" DecorationZoneID="ContentDiv" Skin="Web20" />
        <telerik:RadScriptManager ID="CystoscopyProstateRadScriptManager" runat="Server"></telerik:RadScriptManager>
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false"></telerik:RadNotification>
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
        <div class="abnorHeader">Prostate </div>
        <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Width="100%" Orientation="Horizontal" BorderSize="0" PanesBorderSize="0" Skin="Windows7">
            <telerik:RadPane ID="RadPane1" runat="server" Height="560px" Scrolling="None">
                <asp:ObjectDataSource ID="CystoscopyProstateObjectDataSource" runat="server" TypeName="UnisoftERS.Abnormalities"
                    SelectMethod="GetAbnormalities" UpdateMethod="SaveCystoscopyProstateAbnosData" InsertMethod="SaveCystoscopyProstateAbnosData">
                    <SelectParameters>
                        <asp:Parameter Name="storedProc" DbType="string" DefaultValue="abnormalities_cystoscopy_Prostate_select"></asp:Parameter>
                        <asp:Parameter Name="siteId" DbType="Int32" DefaultValue="0"></asp:Parameter>
                    </SelectParameters>
                    <UpdateParameters>
                        <asp:Parameter Name="siteId" Type="Int32" />
                        <asp:Parameter Name="Normal" Type="Boolean" />
                        <asp:Parameter Name="Irregular" Type="Boolean" />
                        <asp:Parameter Name="Large" Type="Boolean" />
                        <asp:Parameter Name="Obstructive" Type="Boolean" />
                        <asp:Parameter Name="Vascular" Type="Boolean" />
                        <asp:Parameter Name="RedPatch" Type="Boolean" />
                    </UpdateParameters>
                </asp:ObjectDataSource>
                <asp:FormView ID="CystoscopyProstateFormView" runat="server" DefaultMode="Edit" DataSourceID="CystoscopyProstateObjectDataSource" DataKeyNames="SiteId">
                    <EditItemTemplate>
                        <div id="ContentDiv">
                            <div id="siteDetailsContentDiv">
                                <div class="rgview" id="rgAbnormalities" runat="server">


                                    <table id="ProstateTable" runat="server" cellpadding="3" cellspacing="3" class="rgview" style="width: 798px;">

                                        <thead>
                                            <tr>
                                                <th class="rgHeader" style="text-align: left;" colspan="2">
                                                    <asp:CheckBox ID="NoneCheckBox" runat="server" Text="None" ForeColor="Black" Checked='<%# Bind("Normal")%>' />
                                                </th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                           

                                            <tr class="NonUreteric">
                                                <td colspan="2">
                                                    <asp:CheckBox ID="IrregularCheckBox" class="deselectNone" runat="server" Text="Irregular" Checked='<%# Bind("Irregular")%>' />
                                                </td>

                                            </tr>
                                            <tr class="NonUreteric">
                                                <td colspan="2">
                                                    <asp:CheckBox ID="LargeCheckBox" class="deselectNone" runat="server" Text="Large" Checked='<%# Bind("Large")%>' />
                                                </td>

                                            </tr>
                                            <tr class="NonUreteric">
                                                <td colspan="2">
                                                    <asp:CheckBox ID="ObstructiveCheckBox"  class="deselectNone" runat="server" Text="Obstructive" Checked='<%# Bind("Obstructive")%>' />
                                                </td>

                                            </tr>
                                            <tr class="NonUreteric">
                                                <td colspan="2">
                                                    <asp:CheckBox ID="VascularCheckBox" runat="server" Text="Vascular" Checked='<%# Bind("Vascular")%>' />
                                                </td>

                                            </tr>
                                            <tr class="NonUreteric">
                                                <td colspan="2">
                                                    <asp:CheckBox ID="RedPatchCheckBox" runat="server" Text="Red Patch" Checked='<%# Bind("RedPatch")%>' />
                                                </td>

                                            </tr>
                                           

                                        </tbody>
                                    </table>

                                </div>
                            </div>
                        </div>
                    </EditItemTemplate>
                </asp:FormView>
            </telerik:RadPane>
            <telerik:RadPane ID="RadPane2" runat="server" Scrolling="None" Height="33px" CssClass="SiteDetailsButtonsPane">
                <div id="cmdOtherData" style="height: 10px; margin-left: 10px; padding-top: 6px; display: none">
                    <telerik:RadButton ID="SaveButton" runat="server" Text="Save" Skin="Web20" Icon-PrimaryIconCssClass="telerikSaveButton" />
                    <telerik:RadButton ID="CancelButton" runat="server" Text="Close" Skin="Web20" OnClientClicking="CloseWindow" Icon-PrimaryIconCssClass="telerikCancelButton" />

                </div>
            </telerik:RadPane>
        </telerik:RadSplitter>
        </ContentTemplate>
        </asp:UpdatePanel>
    </form>
</body>
</html>

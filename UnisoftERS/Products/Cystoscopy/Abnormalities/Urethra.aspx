<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="Urethra.aspx.vb" Inherits="UnisoftERS.Urethra" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <telerik:RadStyleSheetManager ID="RadStyleSheetManager1" runat="server" />
    <script type="text/javascript" src="../../../Scripts/jquery-3.6.3.min.js"></script>
    <script src="../../../Scripts/global.js"></script>
    <link type="text/css" href="../../../Styles/Site.css" rel="stylesheet" />
    <link type="text/css" href="../../../Styles/Site.css" rel="stylesheet" />
    <telerik:RadScriptBlock runat="server" ID="RadCodeBlock">
        <script type="text/javascript">
            var urethraChanged = false;
            $(window).on('load', function () {
           
                if (!$("#CystoscopyUrethraFormView_TumorCheckBox").is(":checked")) {
                     $("#CystoscopyUrethraFormView_TumorCheckBox").closest("tr").find(".secondCol").hide();

                }
                var regName = ($("#RegionHidden").val());
                if (regName == "Dome" || regName == "Right lateral wall" || regName == "Left lateral wall" || regName == "Urethra" || regName == "Trigone"|| regName == "Dome" ) {
                    $("#CystoscopyUrethraFormView_UrethraTable tr.Ureteric").each(function () {
                        $(this).hide();
                    })
                }
                  if (regName == "Right ureteric orifice" || regName == "Left ureteric orifice") {
                    $("#CystoscopyUrethraFormView_UrethraTable tr.NonUreteric").each(function () {
                        $(this).hide();
                    })
                }
            })
            function CloseWindow() {
                window.parent.CloseWindow();
            }

            $(document).ready(function () {
                $("#CystoscopyUrethraFormView_NoneCheckBox").change(function () {
                  
                    ToggleNoneCheckBox($(this).is(":checked"))
                    valueChanged();
                })

                $("#CystoscopyUrethraFormView_TumorCheckBox").change(function () {
                    var checked = $(this).is(":checked");
                    clearTextBoxOfRow($(this).closest('tr'), checked)
                    toggleSecondColum($(this).closest('tr'), checked)
                })

                //changed by mostafiz issue 3647
                $("#CystoscopyUrethraFormView_UrethraTable tr td:first-child input").change(function () {
                    if ($(this).is(":checked")) {
                         $("#CystoscopyUrethraFormView_NoneCheckBox").prop("checked", false);
                    }
                    valueChanged();
                })

                $(window).on('beforeunload', function () {
                    if (urethraChanged) $('#<%=SaveButton.ClientID%>').click();
                });
                $(window).on('unload', function () {
                    localStorage.clear();
                    setRehideSummary();
                });
            })

            function valueChanged() {
                urethraChanged = true;
                var valueToSave = false;
                $("#CystoscopyUrethraFormView_UrethraTable tr td:first-child").each(function () {
                    if ($(this).find("input:checkbox").is(':checked')) valueToSave = true;
                });
                if (!$('#CystoscopyUrethraFormView_NoneCheckBox').is(':checked') && !valueToSave)
                    localStorage.setItem('valueChanged', 'false');
                else
                    localStorage.setItem('valueChanged', 'true');

            }

            //changed by mostafiz issue 3647
            function clearTextBoxOfRow(closestTR, checked) {
                if (!checked) {

               
                    $(closestTR).find("input:text").each(function () {
                        $('input:text[id=' + $(this).attr('id') + ']').val('')
                    })

                    $(closestTR).find("input:checkbox:checked").each(function () {
                        $('input:checkbox[id=' + $(this).attr('id') + ']').prop("checked", false);
                    })
                }

            }

            function toggleSecondColum(closestTR, checked) {
                if (checked) {
                    $(closestTR).find(".secondCol").show();
                }
                else {
                    $(closestTR).find(".secondCol").hide();
                }
            }
            //changed by mostafiz issue 3647
            function ToggleNoneCheckBox(checked) {

                if (checked) {
                    $("#CystoscopyUrethraFormView_UrethraTable tr td:first-child").each(function () {
                        $(this).find("input:checkbox:checked").prop("checked", false);
                        $(this).find("input:checkbox").trigger("change");

                    })
                }
                else {
                    $("#CystoscopyUrethraFormView_UrethraTable tr td:first-child").each(function () {
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
        <telerik:RadScriptManager ID="CystoscopyUrethraRadScriptManager" runat="Server"></telerik:RadScriptManager>
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false"></telerik:RadNotification>
        
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
        <div class="abnorHeader">Urethra </div>
        <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Width="100%" Orientation="Horizontal" BorderSize="0" PanesBorderSize="0" Skin="Windows7">
            <telerik:RadPane ID="RadPane1" runat="server" Height="560px" Scrolling="None">
                <asp:ObjectDataSource ID="CystoscopyUrethraObjectDataSource" runat="server" TypeName="UnisoftERS.Abnormalities"
                    SelectMethod="GetAbnormalities" UpdateMethod="SaveCystoscopyUrethraAbnosData" InsertMethod="SaveCystoscopyUrethraAbnosData">
                    <SelectParameters>
                        <asp:Parameter Name="storedProc" DbType="string" DefaultValue="abnormalities_cystoscopy_Urethra_select"></asp:Parameter>
                        <asp:Parameter Name="siteId" DbType="Int32" DefaultValue="0"></asp:Parameter>
                    </SelectParameters>
                    <UpdateParameters>
                        <asp:Parameter Name="siteId" Type="Int32" />
                        <asp:Parameter Name="Normal" Type="Boolean" />
                        <asp:Parameter Name="Tumour" Type="Boolean" />
                        <asp:Parameter Name="Blood" Type="Boolean" />
                        <asp:Parameter Name="PosteriorUrethralValves" Type="Boolean" />
                        <asp:Parameter Name="Stricture" Type="Boolean" />
                        <asp:Parameter Name="Tear" Type="Boolean" />
                        <asp:Parameter Name="RedPatch" Type="Boolean" />
                        <asp:Parameter Name="Stones" Type="Boolean" />
                        <asp:Parameter Name="Wart" Type="Boolean" />
                        <asp:Parameter Name="Epispadias" Type="Boolean" />
                        <asp:Parameter Name="Hypospadias" Type="Boolean" />
                        <asp:Parameter Name="Small" Type="Boolean" />

                    
                    </UpdateParameters>
                </asp:ObjectDataSource>
                <asp:FormView ID="CystoscopyUrethraFormView" runat="server" DefaultMode="Edit" DataSourceID="CystoscopyUrethraObjectDataSource" DataKeyNames="SiteId">
                    <EditItemTemplate>
                        <div id="ContentDiv">
                            <div id="siteDetailsContentDiv">
                                <div class="rgview" id="rgAbnormalities" runat="server">


                                    <table id="UrethraTable" runat="server" cellpadding="3" cellspacing="3" class="rgview" style="width: 798px;">

                                        <thead>
                                            <tr>
                                                <th class="rgHeader" style="text-align: left;" colspan="2">
                                                    <asp:CheckBox ID="NoneCheckBox" runat="server" Text="None" ForeColor="Black" Checked='<%# Bind("Normal")%>' />
                                                </th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <tr class="NonUreteric">
                                                <td colspan="2" >
                                                    <asp:CheckBox ID="TumourCheckBox" class="deselectNone" runat="server" Text="Tumor" Checked='<%# Bind("Tumour")%>' />
                                                </td>
                                               
                                            </tr>

                                            <tr class="NonUreteric">
                                                <td colspan="2">
                                                    <asp:CheckBox ID="BloodCheckBox" class="deselectNone" runat="server" Text="Blood" Checked='<%# Bind("Blood")%>' />
                                                </td>

                                            </tr>
                                            <tr class="NonUreteric">
                                                <td colspan="2">
                                                    <asp:CheckBox ID="PosteriorUrethralValvesCheckBox" class="deselectNone" runat="server" Text="PosteriorUrethralValves" Checked='<%# Bind("PosteriorUrethralValves")%>' />
                                                </td>

                                            </tr>
                                            <tr class="NonUreteric">
                                                <td colspan="2">
                                                    <asp:CheckBox ID="StrictureCheckBox"  class="deselectNone" runat="server" Text="Stricture" Checked='<%# Bind("Stricture")%>' />
                                                </td>

                                            </tr>
                                            <tr class="NonUreteric">
                                                <td colspan="2">
                                                    <asp:CheckBox ID="TearCheckBox" runat="server" Text="Tear" Checked='<%# Bind("Tear")%>' />
                                                </td>

                                            </tr>
                                            <tr class="NonUreteric">
                                                <td colspan="2">
                                                    <asp:CheckBox ID="RedPatchCheckBox" runat="server" Text="Red Patch" Checked='<%# Bind("RedPatch")%>' />
                                                </td>

                                            </tr>
                                            <tr class="NonUreteric">
                                                <td colspan="2">
                                                    <asp:CheckBox ID="StonesCheckBox" runat="server" Text="Stones" Checked='<%# Bind("Stones")%>' />
                                                </td>

                                            </tr>

                                            <tr class="Ureteric">
                                                <td colspan="2">
                                                    <asp:CheckBox ID="WartCheckBox" runat="server" Text="Wart" Checked='<%# Bind("Wart")%>' />
                                                </td>

                                            </tr>
                                            <tr class="Ureteric">
                                                <td colspan="2">
                                                    <asp:CheckBox ID="EpispadiasCheckBox" runat="server" Text="Epispadias" Checked='<%# Bind("Epispadias")%>' />
                                                </td>

                                            </tr>
                                            <tr class="Ureteric">
                                                <td colspan="2">
                                                    <asp:CheckBox ID="HypospadiasCheckBox" runat="server" Text="Hypospadias" Checked='<%# Bind("Hypospadias")%>' />
                                                </td>

                                            </tr>
                                            <tr class="Ureteric">
                                                <td colspan="2">
                                                    <asp:CheckBox ID="SmallCheckBox" runat="server" Text="Small" Checked='<%# Bind("Small")%>' />
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
                <div id="cmdOtherData" style="height: 10px; margin-left: 10px; padding-top: 6px; display:none">
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

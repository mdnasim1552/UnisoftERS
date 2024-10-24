<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="Bladder.aspx.vb" Inherits="UnisoftERS.Bladder" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>

    <script type="text/javascript" src="../../../Scripts/jquery-3.6.3.min.js"></script>
    <script src="../../../Scripts/global.js"></script>
    <link type="text/css" href="../../../Styles/Site.css" rel="stylesheet" />

    <telerik:RadScriptBlock runat="server" ID="RadCodeBlock">
        <script type="text/javascript">
            var bladderChanged = false;
            $(window).on('load', function () {
           
                if (!$("#CystoscopyBladderFormView_TumorCheckBox").is(":checked")) {
                     $("#CystoscopyBladderFormView_TumorCheckBox").closest("tr").find(".secondCol").hide();

                }
                var regName = ($("#RegionHidden").val());
                if (regName == "Dome" || regName == "Right lateral wall" || regName == "Left lateral wall" || regName == "Bladder" || regName == "Trigone"|| regName == "Dome" ) {
                    $("#CystoscopyBladderFormView_BladderTable tr.Ureteric").each(function () {
                        $(this).hide();
                    })
                }
                  if (regName == "Right ureteric orifice" || regName == "Left ureteric orifice") {
                    $("#CystoscopyBladderFormView_BladderTable tr.NonUreteric").each(function () {
                        $(this).hide();
                    })
                }
            })
            function CloseWindow() {
                window.parent.CloseWindow();
            }

            $(document).ready(function () {
                $("#CystoscopyBladderFormView_NoneCheckBox").change(function () {

                    ToggleNoneCheckBox($(this).is(":checked"))
                    valueChanged();
                })

                $("#CystoscopyBladderFormView_TumorCheckBox").change(function () {
                    var checked = $(this).is(":checked");
                    clearTextBoxOfRow($(this).closest('tr'), checked)
                    toggleSecondColum($(this).closest('tr'), checked)
                })

                //changed by mostafiz issue 3647
                $("#CystoscopyBladderFormView_BladderTable tr td:first-child input").change(function () {
                    if ($(this).is(":checked")) {
                        $("#CystoscopyBladderFormView_NoneCheckBox").prop("checked", false);
                    }
                    valueChanged();
                })

                $("#CystoscopyBladderFormView_TumorQuantityRadNumericTextBox, CystoscopyBladderFormView_TumorSizeofLargestRadNumericTextBox").change(function () {
                    valueChanged();
                });

                $("#CystoscopyBladderFormView_TumorMultiple, #CystoscopyBladderFormView_TumorFlat, #CystoscopyBladderFormView_TumorFungating, #CystoscopyBladderFormView_TumorPapilary, #CystoscopyBladderFormView_TumorSolid").change(function () {
                    valueChanged();
                });
                $(window).on('beforeunload', function () {
                    if (bladderChanged) $('#<%=SaveButton.ClientID%>').click();
                });
                $(window).on('unload', function () {
                    localStorage.clear();
                    setRehideSummary();
                });
            });
            function valueChanged() {
                bladderChanged = true;
                var valueToSave = false;
                $("#CystoscopyBladderFormView_BladderTable tr td:first-child").each(function () {
                    if ($(this).find("input:checkbox").is(':checked')) valueToSave = true;
                });
                if (!$('#CystoscopyBladderFormView_NoneCheckBox').is(':checked') && !valueToSave)
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
                        $('input:checkbox[id=' + $(this).attr('id') + ']').prop('checked', false);
   
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
                    $("#CystoscopyBladderFormView_BladderTable tr td:first-child").each(function () {
                        $(this).find("input:checkbox:checked").prop('checked', false);
                        $(this).find("input:checkbox").trigger("change");


                    })
                }
                else {
                    $("#CystoscopyBladderFormView_BladderTable tr td:first-child").each(function () {
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
        <telerik:RadScriptManager ID="CystoscopyBladderRadScriptManager" runat="Server"></telerik:RadScriptManager>
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false"></telerik:RadNotification>
        
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
        <div class="abnorHeader">Bladder </div>
        <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Width="100%" Orientation="Horizontal" BorderSize="0" PanesBorderSize="0" Skin="Windows7">
            <telerik:RadPane ID="RadPane1" runat="server" Height="560px" Scrolling="None">
                <asp:ObjectDataSource ID="CystoscopyBladderObjectDataSource" runat="server" TypeName="UnisoftERS.Abnormalities"
                    SelectMethod="GetAbnormalities" UpdateMethod="SaveCystoscopyBladderAbnosData" InsertMethod="SaveCystoscopyBladderAbnosData">
                    <SelectParameters>
                        <asp:Parameter Name="storedProc" DbType="string" DefaultValue="abnormalities_cystoscopy_bladder_select"></asp:Parameter>
                        <asp:Parameter Name="siteId" DbType="Int32" DefaultValue="0"></asp:Parameter>
                    </SelectParameters>
                    <UpdateParameters>
                        <asp:Parameter Name="siteId" Type="Int32" />
                        <asp:Parameter Name="Normal" Type="Boolean" />
                        <asp:Parameter Name="Tumor" Type="Boolean" />
                        <asp:Parameter Name="CystitisCystica" Type="Boolean" />
                        <asp:Parameter Name="Diverticulum" Type="Boolean" />
                        <asp:Parameter Name="Fistula" Type="Boolean" />
                        <asp:Parameter Name="RadiationCystitis" Type="Boolean" />
                        <asp:Parameter Name="RedPatch" Type="Boolean" />
                        <asp:Parameter Name="Stones" Type="Boolean" />
                        <asp:Parameter Name="AbnormalPosition" Type="Boolean" />
                        <asp:Parameter Name="CoveredWithTumour" Type="Boolean" />
                        <asp:Parameter Name="ExtraUretericOrifice" Type="Boolean" />
                        <asp:Parameter Name="Ureterocoele" Type="Boolean" />

                        <asp:Parameter Name="TumorQuantity" Type="Double" />
                        <asp:Parameter Name="TumorSizeofLargest" Type="Double" />
                        <asp:Parameter Name="TumorMultiple" Type="Boolean" />
                        <asp:Parameter Name="TumorFlat" Type="Boolean" />
                        <asp:Parameter Name="TumorFungating" Type="Boolean" />
                        <asp:Parameter Name="TumorPapilary" Type="Boolean" />
                        <asp:Parameter Name="TumorSolid" Type="Boolean" />
                    </UpdateParameters>
                </asp:ObjectDataSource>
                <asp:FormView ID="CystoscopyBladderFormView" runat="server" DefaultMode="Edit" DataSourceID="CystoscopyBladderObjectDataSource" DataKeyNames="SiteId">
                    <EditItemTemplate>
                        <div id="ContentDiv">
                            <div id="siteDetailsContentDiv">
                                <div class="rgview" id="rgAbnormalities" runat="server">


                                    <table id="BladderTable" runat="server" cellpadding="3" cellspacing="3" class="rgview" style="width: 798px;">

                                        <thead>
                                            <tr>
                                                <th class="rgHeader" style="text-align: left;" colspan="2">
                                                    <asp:CheckBox ID="NoneCheckBox" runat="server" Text="None" ForeColor="Black" Checked='<%# Bind("Normal")%>' />
                                                </th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <tr class="NonUreteric">
                                                <td>
                                                    <asp:CheckBox ID="TumorCheckBox" class="deselectNone" runat="server" Text="Tumor" Checked='<%# Bind("Tumor")%>' />
                                                </td>
                                                <td class="secondCol">

                                                    <asp:Label runat="server" Text="Qty:"></asp:Label>
                                                    <telerik:RadNumericTextBox ID="TumorQuantityRadNumericTextBox" runat="server" DbValue='<%# Bind("TumorQuantity")%>'
                                                        IncrementSettings-InterceptMouseWheel="false"
                                                        IncrementSettings-Step="1"
                                                        Width="35px"
                                                        MinValue="0">
                                                        <NumberFormat DecimalDigits="0" />
                                                    </telerik:RadNumericTextBox>
                                                    <asp:Label runat="server" Text="Size of Largest"></asp:Label>
                                                    <telerik:RadNumericTextBox ID="TumorSizeofLargestRadNumericTextBox" runat="server" DbValue='<%# Bind("TumorSizeofLargest")%>'
                                                        IncrementSettings-InterceptMouseWheel="false"
                                                        IncrementSettings-Step="10"
                                                        Width="35px"
                                                        MinValue="0">
                                                        <NumberFormat DecimalDigits="0" />
                                                    </telerik:RadNumericTextBox>
                                                    <asp:Label runat="server" Text="mm"></asp:Label>
                                                    </br>
                                                        </br>
                                                        <asp:CheckBox ID="TumorMultiple" runat="server" Text="Multiple" Checked='<%# Bind("TumorMultiple")%>' />
                                                    <asp:CheckBox ID="TumorFlat" runat="server" Text="Flat" Checked='<%# Bind("TumorFlat")%>' />
                                                    <asp:CheckBox ID="TumorFungating" runat="server" Text="Fungating" Checked='<%# Bind("TumorFungating")%>' />
                                                    <asp:CheckBox ID="TumorPapilary" runat="server" Text="Papilary" Checked='<%# Bind("TumorPapilary")%>' />
                                                    <asp:CheckBox ID="TumorSolid" runat="server" Text="Solid" Checked='<%# Bind("TumorSolid")%>' />


                                                </td>
                                            </tr>

                                            <tr class="NonUreteric">
                                                <td colspan="2">
                                                    <asp:CheckBox ID="CystitisCysticaCheckBox" class="deselectNone" runat="server" Text="Cystitis Cystica" Checked='<%# Bind("CystitisCystica")%>' />
                                                </td>

                                            </tr>
                                            <tr class="NonUreteric">
                                                <td colspan="2">
                                                    <asp:CheckBox ID="DiverticulumCheckBox" class="deselectNone" runat="server" Text="Diverticulum" Checked='<%# Bind("Diverticulum")%>' />
                                                </td>

                                            </tr>
                                            <tr class="NonUreteric">
                                                <td colspan="2">
                                                    <asp:CheckBox ID="FistulaCheckBox"  class="deselectNone" runat="server" Text="Fistula" Checked='<%# Bind("Fistula")%>' />
                                                </td>

                                            </tr>
                                            <tr class="NonUreteric">
                                                <td colspan="2">
                                                    <asp:CheckBox ID="RadiationCystitisCheckBox" runat="server" Text="Radiation Cystitis" Checked='<%# Bind("RadiationCystitis")%>' />
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
                                                    <asp:CheckBox ID="AbnormalPositionCheckBox" runat="server" Text="Abnormal Position" Checked='<%# Bind("AbnormalPosition")%>' />
                                                </td>

                                            </tr>
                                            <tr class="Ureteric">
                                                <td colspan="2">
                                                    <asp:CheckBox ID="CoveredWithTumourCheckBox" runat="server" Text="Covered With Tumour" Checked='<%# Bind("CoveredWithTumour")%>' />
                                                </td>

                                            </tr>
                                            <tr class="Ureteric">
                                                <td colspan="2">
                                                    <asp:CheckBox ID="ExtraUretericOrificeCheckBox" runat="server" Text="Extra Ureteric Orifice" Checked='<%# Bind("ExtraUretericOrifice")%>' />
                                                </td>

                                            </tr>
                                            <tr class="Ureteric">
                                                <td colspan="2">
                                                    <asp:CheckBox ID="UreterocoeleCheckBox" runat="server" Text="Ureterocoele" Checked='<%# Bind("Ureterocoele")%>' />
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

<%@ Control Language="vb" AutoEventWireup="false" CodeBehind="Imaging.ascx.vb" Inherits="UnisoftERS.Imaging" %>
<style type="text/css">
    .ImagingMethodTable td {
        padding-right: 30px !important;
    }

    .DataBoundTable td {
        width: 33.3%;
    }

    .gi-bleeds-button {
        margin-left: 5px;
    }

</style>
<telerik:RadScriptBlock runat="server">
    <script type="text/javascript">
        var autoSaveSuccess;


        $(window).on('load', function () {
            $(".imaging-method-parent input[type='checkbox']").each(function () {
                var classname = $(this).next('label').text().replace(/[^a-zA-Z0-9]/g, "_");//replace(/ /g, "_");
                if ($(this).prop('checked')) {
                    if (classname == "Other") {
                        $("." + classname +"_imaging").closest(".rptImagingItems").show();
                    } else {
                        $("." + classname).closest(".rptImagingItems").show();
                        $("." + classname).closest(".imagingMethods-free-entry-warning").hide();
                    }                                                         
                } else {
                    if (classname == "Other") {
                        $("." + classname + "_imaging").closest(".rptImagingItems").hide();
                    } else {
                        $("." + classname).closest(".rptImagingItems").hide();
                    }
                    //if ($("." + classname).length > 0) {

                    //}
                }
            });

            $(".imaging-method2nd-parent input[type='checkbox']").each(function () {
                var classname = $(this).next('label').text().replace(/[^a-zA-Z0-9]/g, "_");//replace(/ /g, "_");
                if ($(this).prop('checked')) {
                    if (classname == "Other") {
                        $("." + classname + "_imaging2nd").closest(".rptImagingItems2nd").show();
                    } else {
                        $("." + classname).closest(".rptImagingItems2nd").show();
                        $("." + classname).closest(".imagingMethods-free-entry-warning").hide();
                    }
                } else {
                    if (classname == "Other") {
                        $("." + classname + "_imaging2nd").closest(".rptImagingItems2nd").hide();
                    } else {
                        $("." + classname).closest(".rptImagingItems2nd").hide();
                    }
                    //if ($("." + classname).length > 0) {

                    //}
                }
            });

        });

        $(document).ready(function () {
            

            $('.imaging-method-parent input').on('change', function () {
                //auto save
                var id = $(this).closest('td').find('.imaging-method-parent').attr('data-uniqueid');
                var description = $(this).closest('.imaging-method-parent').text().trim().replace(/[^a-zA-Z0-9]/g, "_");//replace(/ /g, "_");
                var checked = $(this).is(':checked');
                if (checked) {
                    var checkedQty = 0;
                    //check if any other checkboxes have been ticked.
                    $('.imaging-method-parent input').each(function (idx, itm) {
                        if ($(itm).is(':checked')) {
                            checkedQty++;
                            return
                        }
                    });
                    if (checkedQty <= 1 && description == "Other") {
                        if (confirm('We strongly recommend against using free text entry over choosing a selected item as per National Data Set regulation. \n Do you still wish to continue?')) {
                            $("." + description + "_imaging").closest(".rptImagingItems").show();
                            $("." + description + "_imaging").closest(".imagingMethods-free-entry-warning").hide();
                        }
                    } else {
                        if (description == "Other") {
                            $("." + description + "_imaging").closest(".rptImagingItems").show();

                        } else {
                            $("." + description).closest(".rptImagingItems").show();
                            if (description != "Other") {
                                $("." + description).closest(".imagingMethods-free-entry-warning").hide();
                            }
                        }
                    }
                    //$("." + description).closest(".rptImagingItems").show();
                    //if (description != "Other") {
                    //    $("." + description).closest(".imagingMethods-free-entry-warning").hide();
                    //}

                } else {
                    if (description == "Other") {
                        $("." + description + "_imaging").closest(".rptImagingItems").hide();
                        $("." + description + "_imaging").closest(".imagingMethod-additional-info").val('');
                    } else {
                        $("." + description).closest(".rptImagingItems").hide();
                        $("." + description).closest(".imagingMethod-additional-info").val('');
                    }                 
                }

                saveImagingMethod(id, 0, checked, '');
            });
            $('.imaging-method2nd-parent input').on('change', function () {
                //auto save
                var id = $(this).closest('td').find('.imaging-method2nd-parent').attr('data-uniqueid');
                var description = $(this).closest('.imaging-method2nd-parent').text().trim().replace(/[^a-zA-Z0-9]/g, "_");//replace(/ /g, "_");
                var checked = $(this).is(':checked');
                if (checked) {
                    var checkedQty = 0;
                    //check if any other checkboxes have been ticked.
                    $('.imaging-method2nd-parent input').each(function (idx, itm) {
                        if ($(itm).is(':checked')) {
                            checkedQty++;
                            return
                        }
                    });
                    if (checkedQty <= 1 && description == "Other") {
                        if (confirm('We strongly recommend against using free text entry over choosing a selected item as per National Data Set regulation. \n Do you still wish to continue?')) {
                            $("." + description + "_imaging2nd").closest(".rptImagingItems2nd").show();
                            $("." + description + "_imaging2nd").closest(".imagingMethods2nd-free-entry-warning").hide();
                        }
                    } else {
                        if (description == "Other") {
                            $("." + description + "_imaging2nd").closest(".rptImagingItems2nd").show();

                        } else {
                            $("." + description).closest(".rptImagingItems2nd").show();
                            if (description != "Other") {
                                $("." + description).closest(".imagingMethods2nd-free-entry-warning").hide();
                            }
                        }
                    }
                    //$("." + description).closest(".rptImagingItems").show();
                    //if (description != "Other") {
                    //    $("." + description).closest(".imagingMethods-free-entry-warning").hide();
                    //}

                } else {
                    if (description == "Other") {
                        $("." + description + "_imaging2nd").closest(".rptImagingItems2nd").hide();
                        $("." + description + "_imaging2nd").closest(".imagingMethod2nd-additional-info").val('');
                    } else {
                        $("." + description).closest(".rptImagingItems").hide();
                        $("." + description).closest(".imagingMethod2nd-additional-info").val('');
                    }
                }

                saveImagingMethod(id, 0, checked, '');
            });
            $('.imagingMethod-additional-info').on('focusout', function () {
                var uniqueid = $(this).attr('data-uniqueid');
                var additionalInfoText = $(this).val();
                var checked = (additionalInfoText != '');

                saveImagingMethod(uniqueid, 0, checked, additionalInfoText);
            });
            $('.imagingMethod2nd-additional-info').on('focusout', function () {
                var uniqueid = $(this).attr('data-uniqueid');
                var additionalInfoText = $(this).val();
                var checked = (additionalInfoText != '');

                saveImagingMethod(uniqueid, 0, checked, additionalInfoText);
            });
            
        });

        function saveImagingMethod(imagingId, childId, checked, additionalInfo) {
            var obj = {};
            obj.procedureId = parseInt(<%= Session(UnisoftERS.Constants.SESSION_PROCEDURE_ID)%>);
            obj.imagingMethodId = parseInt(imagingId);
            obj.checked = checked;
            obj.additionalInfo = additionalInfo;
            $.ajax({
                type: "POST",
                url: "PreProcedure.aspx/saveImagingMethod",
                data: JSON.stringify(obj),
                dataType: "json",
                contentType: "application/json; charset=utf-8",
                success: function () {
                    setRehideSummary();
                },
                error: function (x, y, z) {
                   autoSaveSuccess = false;
                    //show a message
                    var objError = x.responseJSON;
                    var errorString = buildErrorString(objError.Message, 'There was an error saving your data.');

                    $find('<%=RadNotification1.ClientID%>').set_text(errorString);
                    $find('<%=RadNotification1.ClientID%>').show();
                }
            });
        }

       
    </script>
</telerik:RadScriptBlock>
<telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" Title="<div class='aspxValidationSummaryHeader'>Please correct the following</div>"
    Skin="Metro" Position="Center" BorderColor="Red" AutoCloseDelay="0" Width="400" ContentIcon="warning" ShowCloseButton="true" EnableShadow="true" EnableRoundedCorners="true" />
<div class="control-section-header abnorHeader">Imaging</div>
<div class="control-sub-header">Method used</div>

<div class="control-content">


    <asp:Repeater ID="rptImagingMethods" runat="server">
        <HeaderTemplate>
            <table class="ImagingMethodTable Fixed700TableWidth" cellpadding="0" cellspacing="0">
                <tr>
        </HeaderTemplate>
        <ItemTemplate>
            <%# IIf(Container.ItemIndex Mod 6 = 0, "</tr><tr>", "")%>
            <td>
                <asp:CheckBox ID="DataboundCheckbox" runat="server" data-uniqueid='<%# Eval("UniqueId") %>' Text='<%# Eval("Description") %>' CssClass="imaging-method-parent" />
            </td>

        </ItemTemplate>
        <FooterTemplate>
            </table>
        </FooterTemplate>
    </asp:Repeater>

    <asp:Repeater ID="rptImagingMethodAdditionalInfo" runat="server" OnItemDataBound="rptImagingMethodAdditionalInfo_ItemDataBound">   
    <ItemTemplate>       
        <div class="rptImagingItems">
            <br />
            <asp:Label ID="lblAdditionalInfo" Text='<%# Eval("Description") %>' runat="server" CssClass="imagingMethod-parent AddDisplayNone" data-uniqueid='<%# Eval("UniqueId") %>' /><br />
            <telerik:RadTextBox ID="txtAdditionalInfo" runat="server" TextMode="MultiLine" Width="450" Height="105" CssClass="imagingMethod-parent AddDisplayNone imagingMethod-additional-info" data-uniqueid='<%# Eval("UniqueId") %>' /><br />
            <strong runat="server" class="imagingMethods-free-entry-warning AddDisplayNone" style="color: red;">Please refrain from entering your information here. Choose from the list above instead</strong>
        </div>
    </ItemTemplate>
</asp:Repeater>
</div>

<div class="control-sub-header">Imaging</div>

<div class="control-content">


    <asp:Repeater ID="rptImagingMethods2nd" runat="server">
        <HeaderTemplate>
            <table class="ImagingMethodTable Fixed700TableWidth" cellpadding="0" cellspacing="0">
                <tr>
        </HeaderTemplate>
        <ItemTemplate>
            <%# IIf(Container.ItemIndex Mod 2 = 0, "</tr><tr>", "")%>
            <td>
                <asp:CheckBox ID="DataboundCheckbox" runat="server" data-uniqueid='<%# Eval("UniqueId") %>' Text='<%# Eval("Description") %>' CssClass="imaging-method2nd-parent" />
            </td>

        </ItemTemplate>
        <FooterTemplate>
            </table>
        </FooterTemplate>
    </asp:Repeater>

    <asp:Repeater ID="rptImagingMethodAdditionalInfo2nd" runat="server" OnItemDataBound="rptImagingMethodAdditionalInfo2nd_ItemDataBound">   
    <ItemTemplate>       
        <div class="rptImagingItems2nd">
            <br />
            <asp:Label ID="lblAdditionalInfo" Text='<%# Eval("Description") %>' runat="server" CssClass="imagingMethod2nd-parent AddDisplayNone" data-uniqueid='<%# Eval("UniqueId") %>' /><br />
            <telerik:RadTextBox ID="txtAdditionalInfo" runat="server" TextMode="MultiLine" Width="450" Height="105" CssClass="imagingMethod2nd-parent AddDisplayNone imagingMethod2nd-additional-info" data-uniqueid='<%# Eval("UniqueId") %>' /><br />
            <strong runat="server" class="imagingMethods2nd-free-entry-warning AddDisplayNone" style="color: red;">Please refrain from entering your information here. Choose from the list above instead</strong>
        </div>
    </ItemTemplate>
</asp:Repeater>
</div>

<%@ Page Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.Products_Common_PhotosCropTest" Codebehind="PhotosCropTest.aspx.vb" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <telerik:RadStyleSheetManager ID="RadStyleSheetManager1" runat="server" />
    <script type="text/javascript" src="../../Scripts/jquery-3.6.3.min.js"></script>
    <script type="text/javascript" src="../../Scripts/global.js"></script>
    <script src="https://ajax.googleapis.com/ajax/libs/prototype/1.7.0.0/prototype.js" type="text/javascript"></script>
	<script src="https://ajax.googleapis.com/ajax/libs/scriptaculous/1.9.0/scriptaculous.js" type="text/javascript"></script>
	<script type="text/javascript" src="../../Scripts/cropper/cropper.js"></script>
    <script type="text/javascript">
        //$(window).on('load', function () {
        //    alert(1);


        //        new Cropper.Img(
        //			'RadImageGallery1_Image',
        //			{
        //			    onEndCrop: onEndCrop
        //			}
        //		);

        //});

        function onEndCrop(coords, dimensions) {
            //alert(1);
            //$('x1').value = coords.x1;
            //$('y1').value = coords.y1;
            //$('x2').value = coords.x2;
            //$('y2').value = coords.y2;
            //$('width').value = dimensions.width;
            //$('height').value = dimensions.height;
        }

        Event.observe(
			window,
			'load',
			function () {

			    new Cropper.Img(
					'RadImageGallery1_Image',
					{
					    onEndCrop: onEndCrop
					}
				);
			}
		);

    </script>

    <style type="text/css">
        /*.rigItemBox {
            margin-left: 50px;
            margin-top:-30px;
        }

        .rigActiveImage {
            height:400px !important;
            border-color:red;
            border:solid;
        }*/

        .rigItemBox {
            margin-left: 50px;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
    <div>
        <telerik:RadScriptManager ID="SiteDetailsRadScriptManager" runat="server" />
        

        <asp:ObjectDataSource ID="PhotosObjectDataSource" runat="server" SelectMethod="GetPhotoCache" TypeName="UnisoftERS.DataAccess">
            <SelectParameters>
                <asp:Parameter Name="userHostName" DbType="String" />
            </SelectParameters>
        </asp:ObjectDataSource>

        <div style="margin: 10px 5px;" class="text2">
            <table>
                <tr>
                    <td colspan="5">
                        <asp:Label ID="HeaderLabel" runat="server"></asp:Label>
                    </td>
                </tr>
                <tr>
                    <td style="height:2px;"></td>
                </tr>
                <tr style="height:25px;">
                    <td>
                        <asp:RadioButton id="SiteRadioButton" runat="server" GroupName="Photo" Text="Attach to a different site" Font-Size="Smaller"/>
                    </td>
                    <td style="width:3px"></td>
                    <td style="display:none;" id="SiteComboBoxTD" runat="server">
                        <telerik:RadComboBox ID="SiteComboBox" runat="server" Skin="Windows7" Width="200">
                            <Items>
                                <telerik:RadComboBoxItem Text="Site 1 (Posterior in Antrum)" Value="1" />
                                <telerik:RadComboBoxItem Text="Site 2 (Anterior in Upper Body)" Value="2" />
                                <telerik:RadComboBoxItem Text="Site 3 (Both/Either in Bulb)" Value="3" />
                                <telerik:RadComboBoxItem Text="Site 4 (Posterior in Cardia)" Value="4" />
                                <telerik:RadComboBoxItem Text="Site 5 (Anterior in Pylorus)" Value="5" />
                            </Items>
                        </telerik:RadComboBox>
                    </td>
                </tr>
                <tr>
                    <td>
                        <asp:RadioButton id="ProcedureRadioButton" runat="server" GroupName="Photo" Text="Attach to the procedure" Font-Size="Smaller"/>
                    </td>
                </tr>
            </table>
        </div>

       
                <div id="ImageGalleryDiv" style="margin: 10px 10px;">
                    <table>
                        <tr>
                            <td>
                                <telerik:RadImageGallery ID="RadImageGallery1" runat="server" Width="600px" Height="400px"
                                    LoopItems="True" RenderMode="Auto" SkinID="Metro"
                                    DataImageField="Blob" DataThumbnailField="Blob" DataSourceID="PhotosObjectDataSource" BackColor="Transparent">
                                    <ThumbnailsAreaSettings Position="Left" ScrollOrientation="Vertical" ScrollButtonsTrigger="Click" />
                                </telerik:RadImageGallery>
                            </td>
                        </tr>
                    </table>
                </div>
           
                <div style="height: 10px; margin-left: 10px; padding-top: 6px;">
                    <telerik:RadButton ID="AttachButton" runat="server" Text="Attach Photo" Skin="Web20" />
                    <telerik:RadButton ID="DeleteButton" runat="server" Text="Delete from Cache" Skin="Web20" />
                    <telerik:RadButton ID="CancelButton" runat="server" Text="Close" Skin="Office2007" OnClientClicked="CloseWindow" />
                </div>
    </div>
    </form>
</body>
</html>

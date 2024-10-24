Imports System.Web
Imports System.Web.UI
Imports System.ComponentModel
Imports Telerik.Web

Namespace Telerik.Web.UI

    <DefaultProperty("Skin")> _
    <ParseChildren(True)> _
    <PersistChildren(False)> _
    <NonVisualControl> _
    Public Class RadPageStylist
        Inherits Control
        '
        Public Sub New()
        End Sub

        Protected Overrides Sub OnInit(e As EventArgs)
            MyBase.OnInit(e)

            If Not MyBase.DesignMode Then
                If GetCurrent(Page) IsNot Nothing Then
                    Throw New InvalidOperationException("Only one instance of a RadApplicationStylist can be added to the page!")
                End If
                Page.Items(GetType(RadPageStylist)) = Me
            End If

            AddHandler Page.PreRender, New EventHandler(AddressOf Page_PreRender)
        End Sub

        Public Shared Function GetCurrent(page As Page) As RadPageStylist
            If page Is Nothing Then
                Throw New ArgumentNullException("page")
            End If
            Return TryCast(page.Items(GetType(RadPageStylist)), RadPageStylist)
        End Function

        Private Sub Page_PreRender(sender As Object, e As EventArgs)
            ApplySkin(Page.Form)
        End Sub

        Public Sub ApplySkin(target As Control)
            If Not target.Visible Then
                Return
            End If

            If TypeOf target Is ISkinnableControl Then
                DirectCast(target, ISkinnableControl).Skin = Skin
            Else
                For Each child As Control In target.Controls
                    ApplySkin(child)
                Next
            End If
        End Sub

        <Category("Appearance"), DefaultValue(""), Description("")> _
        Public Overridable Property Skin() As String
            Get
                Return (If((ViewState("Skin") Is Nothing), [String].Empty, DirectCast(ViewState("Skin"), String)))
            End Get
            Set(value As String)
                ViewState("Skin") = value
            End Set
        End Property

    End Class
End Namespace

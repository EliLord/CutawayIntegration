using Cutaway;
using UnityEditor;
using UnityEngine;

namespace CutawayEditor
{
	[CustomEditor(typeof(CutawayData))]
	public class CutawayDataEditor : Editor
	{
		private CutawayData cutData;
		private CutawayController controller;

		private CutawayController Controller
		{
			get
			{
				if (controller) 
					return controller;
				
				controller = FindObjectOfType<CutawayController>();
				if(!controller)
					Debug.LogError("Can't Find Cutaway Controller");

				return controller;
			}
		}

		public override void OnInspectorGUI()
		{
			base.OnInspectorGUI();
			cutData = (CutawayData) target;
			if (GUILayout.Button("Use Current Plane Position") && Controller) 
				SetPlaneTransform();
		}

		private void SetPlaneTransform()
		{
			cutData.CuttingPlanePosition = controller.CuttingPlane.transform.localPosition;
			cutData.CuttingPlaneRotation = controller.CuttingPlane.transform.localRotation.eulerAngles;
			EditorUtility.SetDirty(cutData);
		}

	}
}
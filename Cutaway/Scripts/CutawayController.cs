using System.Collections.Generic;
using UnityEngine;

namespace Cutaway
{
	public class CutawayController : MonoBehaviour
	{
		[field: SerializeField] public GameObject CuttingPlane { get; private set; }
		[SerializeField] private Shader originalShader;
		private List<Material> currentMaterials;
		private List<Material> allMaterials;
		private static readonly int CrossSectionColor = Shader.PropertyToID("_CrossSectionColor");
		private static readonly int PlaneNormal = Shader.PropertyToID("_PlaneNormal");
		private static readonly int PlanePosition = Shader.PropertyToID("_PlanePosition");
		private Color fillColor;

		private Vector3 cuttingPlaneLastWorldPos;
		private Quaternion cuttingPlaneLastWorldRot;
		private List<GameObjectListColorPair> currentPairs;

		public void Start()
		{
			currentMaterials = new List<Material>();
			allMaterials = new List<Material>();
		}


		public void OnPlaneMoved()
        {
			if (currentPairs != null)
                SetCuts(currentPairs);
        }

        public void HandleCutData(Vector3 position, Vector3 rotation, List<GameObjectListColorPair> pairs)
        {
            MovePlane(position, rotation);
            currentPairs = pairs;
            SetCuts(pairs);
        }

        private void SetCuts(List<GameObjectListColorPair> pairs)
        {
            foreach (GameObjectListColorPair pair in pairs)
                SetCut(pair.parts, pair.listColor, pair.newShader);
        }

        private void SetCut(List<GameObject> parts, Color color, Shader s)
		{
			currentMaterials.Clear();
			GetAllMaterialsInPartList(parts);
			allMaterials.AddRange(currentMaterials);
			fillColor = color;
			AssignNewShader(s);
		}

		private void GetAllMaterialsInPartList(List<GameObject> list)
		{
			foreach (GameObject objs in list)
				GetAllMaterialsInChildrenRecursively(objs);
		}

		private void GetAllMaterialsInChildrenRecursively(GameObject go)
		{
			if (go == null)
				return;

			Renderer r = go.GetComponent<Renderer>();

			if (r)
			{
				foreach (Material m in r.materials)
					currentMaterials.Add(m);
			}

			foreach (Transform child in go.transform)
			{
				if (child == null)
					continue;
				GetAllMaterialsInChildrenRecursively(child.gameObject);
			}
		}

		private void MovePlane(Vector3 pos, Vector3 rot)
		{
			CuttingPlane.transform.localPosition = pos;
			CuttingPlane.transform.localRotation = Quaternion.Euler(rot);
		}

		private void AssignNewShader(Shader s)
		{
			foreach (Material mat in currentMaterials)
			{
				if (mat != null)
				{
					if (mat.shader == originalShader)
						mat.shader = s;
					SetShaderProperties(mat);
				}
				else
					Debug.Log("Null material");
			}
		}

		private void SetShaderProperties(Material mat)
		{
			mat.SetColor(CrossSectionColor, fillColor);
			mat.SetVector(PlaneNormal, CuttingPlane.transform.TransformVector(new Vector3(0, 0, -1)));
			mat.SetVector(PlanePosition, CuttingPlane.transform.position);
		}

		public void ClearShaders()
		{
			if (allMaterials != null)
			{
				foreach (Material mat in allMaterials)
					mat.shader = originalShader;

				allMaterials.Clear();
			}
			currentPairs.Clear();
		}
	}
}
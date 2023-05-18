using System.Collections.Generic;
using System.Linq;
using Special;
using Special.Parts;
using UnityEngine;

namespace Cutaway
{
	[RequireComponent(typeof(CutawayController))]
	public class CutawaySpecialHandler : SpecialBehaviour
	{
		[SerializeField]
		private CutawayController controller;

		private CutawayData cutInfo;
		private List<GameObjectListColorPair> genericPairs;

		public override void OnAwake()
		{
			base.OnAwake();
			Listen(CutawayData.cutawayEnter, Enter);
			Listen(CutawayData.cutawayExit, Exit);
			genericPairs = new List<GameObjectListColorPair>();
		}

		public override void OnDelete()
		{
			base.OnDelete();

			RemoveListen(CutawayData.cutawayEnter, Exit);
			RemoveListen(CutawayData.cutawayExit, Exit);
		}

		private void Enter(ListenResult result)
		{
			cutInfo = (CutawayData) result.Value;
			genericPairs.Clear();
			foreach (PartListColorPair t in cutInfo.listColorPairs)
			{
				List<string> partNames = CombineParts(t.partListsToCutaway);
				GameObjectListColorPair newPair = new GameObjectListColorPair();
				newPair.parts = new List<GameObject>();
				newPair.parts.AddRange(PartDirectory.GetParts(partNames));
				newPair.listColor = t.listColor;
				newPair.newShader = t.newShader;
				genericPairs.Add(newPair);
			}

			controller.HandleCutData(cutInfo.CuttingPlanePosition, cutInfo.CuttingPlaneRotation, genericPairs);
		}

		private void Exit(ListenResult result)
		{
			controller.ClearShaders();
		}

		private List<string> CombineParts(List<PartList> oldList)
		{
			List<string> combinedParts = new List<string>();
			foreach (PartList partlist in oldList)
			{
				if (partlist != null)
					combinedParts.AddRange(partlist.PartNames);
			}

			return combinedParts.Distinct().ToList();
		}
	}
}
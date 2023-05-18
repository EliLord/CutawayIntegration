using System;
using System.Collections.Generic;
using SpecialFramework;
using UnityEngine;

namespace Cutaway
{
	[CreateAssetMenu(fileName = "Step X - CutawayData", menuName = "AircraftProject/Cutaway Data")]
	public class CutawayData : SpecialScriptableObject
	{
		[SerializeField]
		public List<PartListColorPair> listColorPairs;

		internal const string cutawayEnter = "Cutaway Enter";
		internal const string cutawayExit = "Cutaway Exit";

		public override string EnterID => cutawayEnter;
		public override string ExitID => cutawayExit;

		[field: SerializeField] public Vector3 CuttingPlanePosition { get; set; }
		[field: SerializeField] public Vector3 CuttingPlaneRotation { get; set; }
		
	}
}
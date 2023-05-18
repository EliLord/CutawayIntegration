using System;
using System.Collections.Generic;
using Special.Parts;
using UnityEngine;

namespace Cutaway
{
	[Serializable]
	public class PartListColorPair
	{
		public List<PartList> partListsToCutaway;
		public Color listColor;
		public Shader newShader;
	}
}
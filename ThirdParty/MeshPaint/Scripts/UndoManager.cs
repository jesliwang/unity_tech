using UnityEngine;
using System.Collections;
using System.Collections.Generic;

namespace MeshPainter
{
	[System.Serializable]
	public class UndoManager : ISerializationCallbackReceiver
	{
		const int MaxUndo = 20;
		[SerializeField] int _step = -1;

		public int Step { get { return _step; } set { _step = value; } }

		class State{

			List<KeyValuePair< Texture2D, Color[]>> _state;

			public State(List<Texture2D> textures)
			{
				_state = new List<KeyValuePair<Texture2D, Color[]>>();

				Store(textures);
			}

			public void Store(List<Texture2D> textures)
			{
				foreach (Texture2D t2d in textures)
                {
                    if (null == t2d)
                        continue;
					_state.Add(new KeyValuePair<Texture2D, Color[]> (t2d, t2d.GetPixels (0)));
				}
			}

			public void Restore()
			{
				foreach (KeyValuePair<Texture2D, Color[]> kvp in _state) {
					kvp.Key.SetPixels (kvp.Value);
					kvp.Key.Apply ();
				}
			}
		}

		List<State> _undoState;

		public bool Initialized { get; set; }

		public bool HasUndoRedoPerformed { get; set; }
	
		public UndoManager ()
		{
			if (_undoState == null) {
				_undoState = new List<State> (MaxUndo);
			}
		}

		public void OnBeforeSerialize ()
		{
		}

		public void OnAfterDeserialize ()
		{
			if (!Initialized) {
				Step = -1;

				Initialized = true;
			}
		}

		public  void UndoRedoPerformed ()
		{
			HasUndoRedoPerformed = true;
			RestoreTexture (Step);
		}

		void RestoreTexture (int index)
		{
			if (index > -1 && index < _undoState.Count) {
				_undoState [index].Restore();
			}
		}
	
		public void Record (List<Texture2D> textures)
		{
			State state = new State (textures);

			if (_undoState.Count == 0 || Step > _undoState.Count) {
				Step = -1;
			}

			if (++Step == MaxUndo) {
				Step = 0;
			}

			if (_undoState.Count < MaxUndo) {
				_undoState.Insert (Step, state);
			} else {
				_undoState [Step] = state;
			}
		}	
	}

}
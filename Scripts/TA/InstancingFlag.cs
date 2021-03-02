using UnityEngine;

public class InstancingFlag : MonoBehaviour
{
	#region + STATIC Uniforms

	static class Uniforms
	{
		internal static readonly int _FlagIndex = Shader.PropertyToID("_FlagIndex");
		internal static readonly int _SymbolIndex = Shader.PropertyToID("_SymbolIndex");
	}

    #endregion

#if UNITY_EDITOR
    public bool forceUpdate = false;

    private void Update()
    {
        if (forceUpdate)
        {
            SetInstancingFlag(_flagIndex);
            SetInstancingSymbol(_symbolIndex);
        }
    }
#endif

    private MaterialPropertyBlock _propBlock;
    public int _flagIndex = 0;
    public float _symbolIndex = 0;    //symbol
    public Renderer[] Flag;          //multiple renderer


    public void SetInstancingFlag(int idx = 0)
    {
        if (Flag == null)
            return;

        for (int i = 0; i < Flag.Length; ++i)
        {
            if (Flag != null)
            {
                if (_propBlock == null) _propBlock = new MaterialPropertyBlock();

                Flag[i].GetPropertyBlock(_propBlock);
                _propBlock.SetFloat(Uniforms._FlagIndex, idx);
                Flag[i].SetPropertyBlock(_propBlock);
            }
        }
    }

    public void SetInstancingSymbol(float idx = 0)
    {
        if (Flag == null)
            return;
        //if (Flag[idx - 1] == null)
        //    return;

        for (int i = 0; i < Flag.Length; ++i)
        {
            if (Flag != null)
            {
                if (_propBlock == null) _propBlock = new MaterialPropertyBlock();

                Flag[i].GetPropertyBlock(_propBlock);
                _propBlock.SetFloat(Uniforms._SymbolIndex, idx);
                Flag[i].SetPropertyBlock(_propBlock);
            }
        }
    }

    public void SetActiveFlag(bool isActive)
    {
        if (Flag == null)
            return;

        foreach(var e in Flag)
        {
            if (e == null)
                continue;

            e.gameObject.SetActive(isActive);
        }
    }
}
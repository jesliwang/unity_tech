//
// Kino/Bokeh - Depth of field effect
//
// Copyright (C) 2016 Unity Technologies
// Copyright (C) 2015 Keijiro Takahashi
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#if !defined(KERNEL_SMALL) && !defined(KERNEL_MEDIUM)

static const int kSampleCount = 1;
static const float2 kDiskKernel[1] = { float2(0, 0) };

#endif

#if defined(KERNEL_SMALL)

static const int kSampleCount = 1;
static const float2 kDiskKernel[1] = { float2(0, 0) };

#endif

#if defined(KERNEL_MEDIUM)
// rings = 3
// points per ring = 7
static const int kSampleCount = 22;
static const float2 kDiskKernel[kSampleCount] = {
	float2(0,0),
	float2(0.53333336,0),
	float2(0.3325279,0.4169768),
	float2(-0.11867785,0.5199616),
	float2(-0.48051673,0.2314047),
	float2(-0.48051673,-0.23140468),
	float2(-0.11867763,-0.51996166),
	float2(0.33252785,-0.4169769),
	float2(1,0),
	float2(0.90096885,0.43388376),
	float2(0.6234898,0.7818315),
	float2(0.22252098,0.9749279),
	float2(-0.22252095,0.9749279),
	float2(-0.62349,0.7818314),
	float2(-0.90096885,0.43388382),
	float2(-1,0),
	float2(-0.90096885,-0.43388376),
	float2(-0.6234896,-0.7818316),
	float2(-0.22252055,-0.974928),
	float2(0.2225215,-0.9749278),
	float2(0.6234897,-0.7818316),
	float2(0.90096885,-0.43388376),
};
#endif

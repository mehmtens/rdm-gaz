param(
    [Parameter(Mandatory = $true)]
    [string]$SourceRoot
)

Add-Type -AssemblyName System.Drawing

Add-Type -ReferencedAssemblies System.Drawing -TypeDefinition @'
using System;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;
using System.IO;
using System.Runtime.InteropServices;

public static class PixelAssetPrep {
    static bool IsBackground(byte b, byte g, byte r, byte a) {
        if (a == 0) return true;
        int max = Math.Max(r, Math.Max(g, b));
        int min = Math.Min(r, Math.Min(g, b));
        return min >= 225 && (max - min) <= 14;
    }

    public static void Convert(string source, string destination, int outputWidth, int outputHeight, int maxWidth, int maxHeight, int bottomPadding) {
        using (var raw = new Bitmap(source))
        using (var bitmap = new Bitmap(raw.Width, raw.Height, PixelFormat.Format32bppArgb)) {
            using (var graphics = Graphics.FromImage(bitmap)) {
                graphics.CompositingMode = CompositingMode.SourceCopy;
                graphics.DrawImageUnscaled(raw, 0, 0);
            }

            var rectangle = new Rectangle(0, 0, bitmap.Width, bitmap.Height);
            var data = bitmap.LockBits(rectangle, ImageLockMode.ReadWrite, PixelFormat.Format32bppArgb);
            int stride = data.Stride;
            int length = Math.Abs(stride) * bitmap.Height;
            var pixels = new byte[length];
            Marshal.Copy(data.Scan0, pixels, 0, length);

            if (pixels[3] == 255) {
                int total = bitmap.Width * bitmap.Height;
                int head = 0;
                int tail = 0;
                var queue = new int[total];
                var visited = new byte[total];
                Action<int, int> enqueue = (x, y) => {
                    int key = y * bitmap.Width + x;
                    if (visited[key] != 0) return;
                    int offset = y * stride + x * 4;
                    if (IsBackground(pixels[offset], pixels[offset + 1], pixels[offset + 2], pixels[offset + 3])) {
                        visited[key] = 1;
                        queue[tail++] = key;
                    }
                };

                for (int x = 0; x < bitmap.Width; x++) {
                    enqueue(x, 0);
                    enqueue(x, bitmap.Height - 1);
                }
                for (int y = 0; y < bitmap.Height; y++) {
                    enqueue(0, y);
                    enqueue(bitmap.Width - 1, y);
                }

                while (head < tail) {
                    int key = queue[head++];
                    int x = key % bitmap.Width;
                    int y = key / bitmap.Width;
                    int offset = y * stride + x * 4;
                    pixels[offset + 3] = 0;
                    if (x > 0) enqueue(x - 1, y);
                    if (x + 1 < bitmap.Width) enqueue(x + 1, y);
                    if (y > 0) enqueue(x, y - 1);
                    if (y + 1 < bitmap.Height) enqueue(x, y + 1);
                }
            }

            int minX = bitmap.Width;
            int minY = bitmap.Height;
            int maxX = -1;
            int maxY = -1;
            for (int y = 0; y < bitmap.Height; y++) {
                for (int x = 0; x < bitmap.Width; x++) {
                    int offset = y * stride + x * 4;
                    if (pixels[offset + 3] <= 8) continue;
                    minX = Math.Min(minX, x);
                    minY = Math.Min(minY, y);
                    maxX = Math.Max(maxX, x);
                    maxY = Math.Max(maxY, y);
                }
            }

            Marshal.Copy(pixels, 0, data.Scan0, length);
            bitmap.UnlockBits(data);
            if (maxX < minX || maxY < minY) throw new Exception("No visible pixels: " + source);

            int cropWidth = maxX - minX + 1;
            int cropHeight = maxY - minY + 1;
            double scale = Math.Min((double)maxWidth / cropWidth, (double)maxHeight / cropHeight);
            int drawWidth = Math.Max(1, (int)Math.Round(cropWidth * scale));
            int drawHeight = Math.Max(1, (int)Math.Round(cropHeight * scale));
            int drawX = (outputWidth - drawWidth) / 2;
            int drawY = outputHeight - bottomPadding - drawHeight;

            using (var output = new Bitmap(outputWidth, outputHeight, PixelFormat.Format32bppArgb))
            using (var graphics = Graphics.FromImage(output)) {
                graphics.Clear(Color.Transparent);
                graphics.CompositingMode = CompositingMode.SourceCopy;
                graphics.InterpolationMode = InterpolationMode.NearestNeighbor;
                graphics.PixelOffsetMode = PixelOffsetMode.Half;
                graphics.SmoothingMode = SmoothingMode.None;
                graphics.DrawImage(bitmap, new Rectangle(drawX, drawY, drawWidth, drawHeight), new Rectangle(minX, minY, cropWidth, cropHeight), GraphicsUnit.Pixel);
                Directory.CreateDirectory(Path.GetDirectoryName(destination));
                output.Save(destination, ImageFormat.Png);
            }
        }
    }
}
'@

$gazelle = @(
    @('exec-2b9585b7-9e15-4738-8b24-8eec0aeaa167.png', 'placeholder_bound_idle.png'),
    @('exec-9cb54421-a961-42a0-87ca-42aca6a1e12a.png', 'placeholder_flinch.png'),
    @('exec-75353bfc-5c6d-4a9f-84d8-7d71e035e879.png', 'placeholder_rescue_react.png'),
    @('exec-6724c6f4-7d70-4212-bae9-8eeed87476fa.png', 'placeholder_freed.png'),
    @('exec-28b52776-769c-4a3b-a76e-3b8a0e213998.png', 'placeholder_rescue_pose.png')
)

$pickups = @(
    @('exec-8da45d57-9110-4869-9c7a-47844103f678.png', 'placeholder_ammo.png'),
    @('exec-bfc15974-3695-4e76-8e99-0f73a51e59c9.png', 'placeholder_armor.png'),
    @('exec-2b4c2fc7-cc07-42f7-a07b-b89c67356c5b.png', 'placeholder_bat.png'),
    @('exec-751b442a-fc96-437a-8590-171799aa5114.png', 'placeholder_coin.png'),
    @('exec-a0798693-7080-4702-a9e5-51b75f66a9c2.png', 'placeholder_health.png'),
    @('exec-6a4a7e97-0641-4aa6-b4cb-46a80c4112fa.png', 'placeholder_invis.png'),
    @('exec-6464974b-a869-4ebb-8b9a-ff9903238f03.png', 'placeholder_dmg2x.png'),
    @('exec-15e4bfac-017d-445e-bae0-d7dbc951f2e8.png', 'placeholder_pistol.png'),
    @('exec-ecde6048-1787-482c-9af9-cdf61fa1e7e6.png', 'placeholder_knife.png'),
    @('exec-93ba4369-fa86-4016-9268-f3a34ea3eecc.png', 'placeholder_shield.png'),
    @('exec-3cc08808-5697-4799-b042-73fc85844695.png', 'placeholder_speed.png')
)

$workspace = Split-Path -Parent $PSScriptRoot
$gazelleDestination = Join-Path $workspace 'redmount\assets\characters\gazelle'
$pickupDestination = Join-Path $workspace 'redmount\assets\pickups'

foreach ($mapping in $gazelle) {
    [PixelAssetPrep]::Convert((Join-Path $SourceRoot $mapping[0]), (Join-Path $gazelleDestination $mapping[1]), 128, 256, 112, 236, 6)
}
foreach ($mapping in $pickups) {
    [PixelAssetPrep]::Convert((Join-Path $SourceRoot $mapping[0]), (Join-Path $pickupDestination $mapping[1]), 48, 48, 42, 42, 3)
}

Write-Output 'Generated assets processed successfully.'

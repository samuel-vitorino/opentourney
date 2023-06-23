<script lang="ts">
    import { Tabs, TabItem, P, Table, TableBody, TableBodyCell, TableBodyRow, TableHead, TableHeadCell } from 'flowbite-svelte';

    interface Match {
        status: number;
    }

    let match = {} as Match;

    match.status = 3
</script>

<div class="flex flex-col w-full shadow-md">
    <div class="box-content p-4">
        <Tabs style="underline">
            <TabItem open>
                <div slot="title" class="flex items-center gap-2">Overview</div>
                <div class="flex justify-center h-[120px]">
                    <div class="flex items-center mr-5">
                        <P weight="semibold" class="mr-3">Team Pedro</P>
                        <img
                            class="w-10 h-10 rounded-full"
                            src="/images/placeholder.png"
                            alt="Jese"
                        />
                    </div>
                    <div class="flex items-center">
                        <P color="text-green-500" class="mr-5" size="3xl" weight="bold">16</P>
                        <div class="flex flex-col items-center mr-5">
                            <P size="sm">5v5</P>
                            <P weight="semibold">Finished</P>
                            <P size="xs">Best of 1</P>
                        </div>
                        <P weight="bold" color="text-gray-600" size="3xl">14</P>
                    </div>
                    <div class="flex items-center ml-5">
                        <img
                            class="w-10 h-10 rounded-full"
                            src="/images/placeholder.png"
                            alt="Jese"
                        />
                        <P weight="semibold" class="ml-3">Team Tomas</P>
                    </div>
                </div>
                <hr class="mt-5 mb-5">
                <div class="flex justify-between">
                    <div class="flex flex-col w-[350px] h-[380px] justify-between"> 
                        <div class="flex items-center box-content p-3 rounded-md border">
                            <P weight="semibold" class="mr-3">Pedro</P>
                            <img
                                class="w-10 h-10 rounded-full"
                                src="/images/placeholder.png"
                                alt="Jese"
                            />
                        </div>
                        <div class="flex items-center box-content p-3 rounded-md border">
                            <P weight="semibold" class="mr-3">Pedro</P>
                            <img
                                class="w-10 h-10 rounded-full"
                                src="/images/placeholder.png"
                                alt="Jese"
                            />
                        </div>
                        <div class="flex items-center box-content p-3 rounded-md border">
                            <P weight="semibold" class="mr-3">Pedro</P>
                            <img
                                class="w-10 h-10 rounded-full"
                                src="/images/placeholder.png"
                                alt="Jese"
                            />
                        </div>
                        <div class="flex items-center box-content p-3 rounded-md border">
                            <P weight="semibold" class="mr-3">Pedro</P>
                            <img
                                class="w-10 h-10 rounded-full"
                                src="/images/placeholder.png"
                                alt="Jese"
                            />
                        </div>
                        <div class="flex items-center box-content p-3 rounded-md border">
                            <P weight="semibold" class="mr-3">Pedro</P>
                            <img
                                class="w-10 h-10 rounded-full"
                                src="/images/placeholder.png"
                                alt="Jese"
                            />
                        </div>
                    </div>
                    <div>
                        {#if match.status == 0}
                            <div>
                                <P weight="semibold">Waiting for match to start</P>
                            </div>
                        {:else if match.status == 1}
                            <div class="flex flex-col justify-between h-[400px]">
                                <div class="flex flex-col w-[350px] h-[20px] bg-gray-200 box-content justify-center rounded-md p-4">
                                    <div class="flex items-center">
                                        <img src="/images/d2.jpg" class="mr-5 w-[60px] h-[40px] rounded-md" alt="Server location flag">
                                        <P weight="semibold" size="sm">Dust 2</P>
                                    </div>
                                </div>
                                <div class="flex flex-col w-[350px] h-[20px] bg-gray-200 box-content justify-center rounded-md p-4">
                                    <div class="flex items-center">
                                        <img src="/images/mirage.jpg" class="mr-5 w-[60px] h-[40px] rounded-md" alt="Server location flag">
                                        <P weight="semibold" size="sm">Mirage</P>
                                    </div>
                                </div>
                                <div class="flex flex-col w-[350px] h-[20px] bg-gray-200 box-content justify-center rounded-md p-4">
                                    <div class="flex items-center">
                                        <img src="/images/ancient.jpg" class="mr-5 w-[60px] h-[40px] rounded-md" alt="Server location flag">
                                        <P weight="semibold" size="sm">Ancient</P>
                                    </div>
                                </div>
                                <div class="flex flex-col w-[350px] h-[20px] bg-gray-200 box-content justify-center rounded-md p-4">
                                    <div class="flex items-center">
                                        <img src="/images/vertigo.png" class="mr-5 w-[60px] h-[40px] rounded-md" alt="Server location flag">
                                        <P weight="semibold" size="sm">Vertigo</P>
                                    </div>
                                </div>
                                <div class="flex flex-col w-[350px] h-[20px] bg-gray-200 box-content justify-center rounded-md p-4">
                                    <div class="flex items-center">
                                        <img src="/images/anubis.jpg" class="mr-5 w-[60px] h-[40px] rounded-md" alt="Server location flag">
                                        <P weight="semibold" size="sm">Anubis</P>
                                    </div>
                                </div>
                                <div class="flex flex-col w-[350px] h-[20px] bg-gray-200 box-content justify-center rounded-md p-4">
                                    <div class="flex items-center">
                                        <img src="/images/overpass.jpg" class="mr-5 w-[60px] h-[40px] rounded-md" alt="Server location flag">
                                        <P weight="semibold" size="sm">Overpass</P>
                                    </div>
                                </div>
                                <div class="flex flex-col w-[350px] h-[20px] bg-gray-200 box-content justify-center rounded-md p-4">
                                    <div class="flex items-center">
                                        <img src="/images/nuke.jpg" class="mr-5 w-[60px] h-[40px] rounded-md" alt="Server location flag">
                                        <P weight="semibold" size="sm">Nuke</P>
                                    </div>
                                </div>
                            </div>
                        {:else if match.status == 2}
                            <P weight="semibold" size="sm" class="mb-2">Ip address</P>
                            <div class="flex flex-col w-[350px] h-[20px] bg-gray-200 box-content justify-center rounded-md p-4">
                                <P>127.0.0.1:5550</P>
                            </div>
                            <P weight="semibold" size="sm" class="mt-5 mb-2">Map</P>
                            <div class="flex flex-col w-[350px] h-[20px] bg-gray-200 box-content justify-center rounded-md p-4">
                                <div class="flex items-center">
                                    <img src="/images/d2.jpg" class="mr-5 w-[60px] h-[40px] rounded-md" alt="Server location flag">
                                    <P weight="semibold" size="sm">Dust_2</P>
                                </div>
                            </div>
                        {:else}
                            <P weight="semibold" size="sm" class="mb-2">Server</P>
                            <div class="flex flex-col w-[350px] h-[20px] bg-gray-200 box-content justify-center rounded-md p-4">
                                <div class="flex items-center">
                                    <img src="/images/portugal.png" class="mr-5 w-[60px] h-[40px] rounded-md" alt="Server location flag">
                                    <P weight="semibold" size="sm">Portugal</P>
                                </div>
                            </div>
                            <P weight="semibold" size="sm" class="mt-5 mb-2">Map</P>
                            <div class="flex flex-col w-[350px] h-[20px] bg-gray-200 box-content justify-center rounded-md p-4">
                                <div class="flex items-center">
                                    <img src="/images/d2.jpg" class="mr-5 w-[60px] h-[40px] rounded-md" alt="Server location flag">
                                    <P weight="semibold" size="sm">Dust 2</P>
                                </div>
                            </div>
                            <div class="w-full flex justify-center mt-[50px]">
                                <P weight="semibold" size="sm" color="text-orange-500">WATCH DEMO</P>
                            </div>
                        {/if}

                    </div>
                    <div class="flex flex-col w-[350px] h-[380px] justify-between"> 
                        <div class="flex items-center justify-end box-content p-3 rounded-md border">
                            <img
                                class="w-10 h-10 rounded-full"
                                src="/images/placeholder.png"
                                alt="Jese"
                            />
                            <P weight="semibold" class="ml-3">Pedro</P>
                        </div>
                        <div class="flex items-center justify-end box-content p-3 rounded-md border">
                            <img
                                class="w-10 h-10 rounded-full"
                                src="/images/placeholder.png"
                                alt="Jese"
                            />
                            <P weight="semibold" class="ml-3">Pedro</P>
                        </div>
                        <div class="flex items-center justify-end box-content p-3 rounded-md border">
                            <img
                                class="w-10 h-10 rounded-full"
                                src="/images/placeholder.png"
                                alt="Jese"
                            />
                            <P weight="semibold" class="ml-3">Pedro</P>
                        </div>
                        <div class="flex items-center justify-end box-content p-3 rounded-md border">
                            <img
                                class="w-10 h-10 rounded-full"
                                src="/images/placeholder.png"
                                alt="Jese"
                            />
                            <P weight="semibold" class="ml-3">Pedro</P>
                        </div>
                        <div class="flex items-center justify-end box-content p-3 rounded-md border">
                            <img
                                class="w-10 h-10 rounded-full"
                                src="/images/placeholder.png"
                                alt="Jese"
                            />
                            <P weight="semibold" class="ml-3">Pedro</P>
                        </div>
                    </div>
                </div>
            </TabItem>
            <TabItem open>
                <div slot="title" class="flex items-center gap-2">Scoreboard</div>
                <div class="flex justify-center h-[120px]">
                    <div class="flex items-center mr-5">
                        <P weight="semibold" class="mr-3">Team Pedro</P>
                        <img
                            class="w-10 h-10 rounded-full"
                            src="/images/placeholder.png"
                            alt="Jese"
                        />
                    </div>
                    <div class="flex items-center">
                        <P color="text-green-500" class="mr-5" size="3xl" weight="bold">16</P>
                        <div class="flex flex-col items-center mr-5">
                            <P size="sm">5v5</P>
                            <P weight="semibold">Finished</P>
                            <P size="xs">Best of 1</P>
                        </div>
                        <P weight="bold" color="text-gray-600" size="3xl">14</P>
                    </div>
                    <div class="flex items-center ml-5">
                        <img
                            class="w-10 h-10 rounded-full"
                            src="/images/placeholder.png"
                            alt="Jese"
                        />
                        <P weight="semibold" class="ml-3">Team Tomas</P>
                    </div>
                </div>
                <hr class="mt-5 mb-5">
                <div class="flex mb-3 justify-between w-full">
                    <div class="flex">
                        <img
                            class="w-5 h-5 rounded-full"
                            src="/images/placeholder.png"
                            alt="Jese"
                        />
                        <P size="sm" class="ml-3" weight="semibold">Team Pedro</P>
                    </div>
                    <div class="flex">
                        <P size="sm" class="ml-3" color="text-gray-500" weight="semibold">LOSS</P>
                        <P size="sm" class="ml-3" weight="semibold">First Half Score: 8</P>
                        <P size="sm" class="ml-3" weight="semibold">Second Half Score: 8</P>
                        <P size="sm" class="ml-3" weight="semibold">Final Score: 16</P>
                    </div>
                </div>
                <Table>
                    <TableHead>
                        <TableHeadCell>Player</TableHeadCell>
                        <TableHeadCell>Kills</TableHeadCell>
                        <TableHeadCell>Assists</TableHeadCell>
                        <TableHeadCell>Deaths</TableHeadCell>
                        <TableHeadCell>K/R Ratio</TableHeadCell>
                        <TableHeadCell>K/D Ratio</TableHeadCell>
                        <TableHeadCell>Headshots</TableHeadCell>
                        <TableHeadCell>Headshots %</TableHeadCell>
                        <TableHeadCell>MVPs</TableHeadCell>
                        <TableHeadCell>Triple Kills</TableHeadCell>
                        <TableHeadCell>Quadro Kills</TableHeadCell>
                        <TableHeadCell>Penta Kills</TableHeadCell>
                    </TableHead>
                    <TableBody tableBodyClass="divide-y">
                        <TableBodyRow class="h-[10px]">
                            <TableBodyCell>
                                <div class="flex items-center">
                                    <P size="sm" class="mr-3">Pedro</P>
                                    <img
                                        class="w-5 h-5 rounded-full"
                                        src="/images/placeholder.png"
                                        alt="Jese"
                                    />
                                </div>
                            </TableBodyCell>
                            <TableBodyCell>30</TableBodyCell>
                            <TableBodyCell>20</TableBodyCell>
                            <TableBodyCell>15</TableBodyCell>
                            <TableBodyCell>1.5</TableBodyCell>
                            <TableBodyCell>2</TableBodyCell>
                            <TableBodyCell>15</TableBodyCell>
                            <TableBodyCell>50%</TableBodyCell>
                            <TableBodyCell>5</TableBodyCell>
                            <TableBodyCell>3</TableBodyCell>
                            <TableBodyCell>5</TableBodyCell>
                            <TableBodyCell>2</TableBodyCell>
                        </TableBodyRow>
                        <TableBodyRow>
                            <TableBodyCell>
                                <div class="flex items-center">
                                    <P size="sm" class="mr-3">Pedro</P>
                                    <img
                                        class="w-5 h-5 rounded-full"
                                        src="/images/placeholder.png"
                                        alt="Jese"
                                    />
                                </div>
                            </TableBodyCell>
                            <TableBodyCell>30</TableBodyCell>
                            <TableBodyCell>20</TableBodyCell>
                            <TableBodyCell>15</TableBodyCell>
                            <TableBodyCell>1.5</TableBodyCell>
                            <TableBodyCell>2</TableBodyCell>
                            <TableBodyCell>15</TableBodyCell>
                            <TableBodyCell>50%</TableBodyCell>
                            <TableBodyCell>5</TableBodyCell>
                            <TableBodyCell>3</TableBodyCell>
                            <TableBodyCell>5</TableBodyCell>
                            <TableBodyCell>2</TableBodyCell>
                        </TableBodyRow>
                        <TableBodyRow>
                            <TableBodyCell>
                                <div class="flex items-center">
                                    <P size="sm" class="mr-3">Pedro</P>
                                    <img
                                        class="w-5 h-5 rounded-full"
                                        src="/images/placeholder.png"
                                        alt="Jese"
                                    />
                                </div>
                            </TableBodyCell>
                            <TableBodyCell>30</TableBodyCell>
                            <TableBodyCell>20</TableBodyCell>
                            <TableBodyCell>15</TableBodyCell>
                            <TableBodyCell>1.5</TableBodyCell>
                            <TableBodyCell>2</TableBodyCell>
                            <TableBodyCell>15</TableBodyCell>
                            <TableBodyCell>50%</TableBodyCell>
                            <TableBodyCell>5</TableBodyCell>
                            <TableBodyCell>3</TableBodyCell>
                            <TableBodyCell>5</TableBodyCell>
                            <TableBodyCell>2</TableBodyCell>
                        </TableBodyRow>
                        <TableBodyRow>
                            <TableBodyCell>
                                <div class="flex items-center">
                                    <P size="sm" class="mr-3">Pedro</P>
                                    <img
                                        class="w-5 h-5 rounded-full"
                                        src="/images/placeholder.png"
                                        alt="Jese"
                                    />
                                </div>
                            </TableBodyCell>
                            <TableBodyCell>30</TableBodyCell>
                            <TableBodyCell>20</TableBodyCell>
                            <TableBodyCell>15</TableBodyCell>
                            <TableBodyCell>1.5</TableBodyCell>
                            <TableBodyCell>2</TableBodyCell>
                            <TableBodyCell>15</TableBodyCell>
                            <TableBodyCell>50%</TableBodyCell>
                            <TableBodyCell>5</TableBodyCell>
                            <TableBodyCell>3</TableBodyCell>
                            <TableBodyCell>5</TableBodyCell>
                            <TableBodyCell>2</TableBodyCell>
                        </TableBodyRow>
                        <TableBodyRow>
                            <TableBodyCell>
                                <div class="flex items-center">
                                    <P size="sm" class="mr-3">Pedro</P>
                                    <img
                                        class="w-5 h-5 rounded-full"
                                        src="/images/placeholder.png"
                                        alt="Jese"
                                    />
                                </div>
                            </TableBodyCell>
                            <TableBodyCell>30</TableBodyCell>
                            <TableBodyCell>20</TableBodyCell>
                            <TableBodyCell>15</TableBodyCell>
                            <TableBodyCell>1.5</TableBodyCell>
                            <TableBodyCell>2</TableBodyCell>
                            <TableBodyCell>15</TableBodyCell>
                            <TableBodyCell>50%</TableBodyCell>
                            <TableBodyCell>5</TableBodyCell>
                            <TableBodyCell>3</TableBodyCell>
                            <TableBodyCell>5</TableBodyCell>
                            <TableBodyCell>2</TableBodyCell>
                        </TableBodyRow>
                    </TableBody>
                </Table>
                <div class="flex mb-3 mt-5 justify-between w-full">
                    <div class="flex">
                        <img
                            class="w-5 h-5 rounded-full"
                            src="/images/placeholder.png"
                            alt="Jese"
                        />
                        <P size="sm" class="ml-3" weight="semibold">Team Pedro</P>
                    </div>
                    <div class="flex">
                        <P size="sm" class="ml-3" color="text-gray-500" weight="semibold">LOSS</P>
                        <P size="sm" class="ml-3" weight="semibold">First Half Score: 8</P>
                        <P size="sm" class="ml-3" weight="semibold">Second Half Score: 8</P>
                        <P size="sm" class="ml-3" weight="semibold">Final Score: 16</P>
                    </div>
                </div>
                <Table>
                    <TableHead>
                        <TableHeadCell>Player</TableHeadCell>
                        <TableHeadCell>Kills</TableHeadCell>
                        <TableHeadCell>Assists</TableHeadCell>
                        <TableHeadCell>Deaths</TableHeadCell>
                        <TableHeadCell>K/R Ratio</TableHeadCell>
                        <TableHeadCell>K/D Ratio</TableHeadCell>
                        <TableHeadCell>Headshots</TableHeadCell>
                        <TableHeadCell>Headshots %</TableHeadCell>
                        <TableHeadCell>MVPs</TableHeadCell>
                        <TableHeadCell>Triple Kills</TableHeadCell>
                        <TableHeadCell>Quadro Kills</TableHeadCell>
                        <TableHeadCell>Penta Kills</TableHeadCell>
                    </TableHead>
                    <TableBody tableBodyClass="divide-y">
                        <TableBodyRow class="h-[10px]">
                            <TableBodyCell>
                                <div class="flex items-center">
                                    <P size="sm" class="mr-3">Pedro</P>
                                    <img
                                        class="w-5 h-5 rounded-full"
                                        src="/images/placeholder.png"
                                        alt="Jese"
                                    />
                                </div>
                            </TableBodyCell>
                            <TableBodyCell>30</TableBodyCell>
                            <TableBodyCell>20</TableBodyCell>
                            <TableBodyCell>15</TableBodyCell>
                            <TableBodyCell>1.5</TableBodyCell>
                            <TableBodyCell>2</TableBodyCell>
                            <TableBodyCell>15</TableBodyCell>
                            <TableBodyCell>50%</TableBodyCell>
                            <TableBodyCell>5</TableBodyCell>
                            <TableBodyCell>3</TableBodyCell>
                            <TableBodyCell>5</TableBodyCell>
                            <TableBodyCell>2</TableBodyCell>
                        </TableBodyRow>
                        <TableBodyRow>
                            <TableBodyCell>
                                <div class="flex items-center">
                                    <P size="sm" class="mr-3">Pedro</P>
                                    <img
                                        class="w-5 h-5 rounded-full"
                                        src="/images/placeholder.png"
                                        alt="Jese"
                                    />
                                </div>
                            </TableBodyCell>
                            <TableBodyCell>30</TableBodyCell>
                            <TableBodyCell>20</TableBodyCell>
                            <TableBodyCell>15</TableBodyCell>
                            <TableBodyCell>1.5</TableBodyCell>
                            <TableBodyCell>2</TableBodyCell>
                            <TableBodyCell>15</TableBodyCell>
                            <TableBodyCell>50%</TableBodyCell>
                            <TableBodyCell>5</TableBodyCell>
                            <TableBodyCell>3</TableBodyCell>
                            <TableBodyCell>5</TableBodyCell>
                            <TableBodyCell>2</TableBodyCell>
                        </TableBodyRow>
                        <TableBodyRow>
                            <TableBodyCell>
                                <div class="flex items-center">
                                    <P size="sm" class="mr-3">Pedro</P>
                                    <img
                                        class="w-5 h-5 rounded-full"
                                        src="/images/placeholder.png"
                                        alt="Jese"
                                    />
                                </div>
                            </TableBodyCell>
                            <TableBodyCell>30</TableBodyCell>
                            <TableBodyCell>20</TableBodyCell>
                            <TableBodyCell>15</TableBodyCell>
                            <TableBodyCell>1.5</TableBodyCell>
                            <TableBodyCell>2</TableBodyCell>
                            <TableBodyCell>15</TableBodyCell>
                            <TableBodyCell>50%</TableBodyCell>
                            <TableBodyCell>5</TableBodyCell>
                            <TableBodyCell>3</TableBodyCell>
                            <TableBodyCell>5</TableBodyCell>
                            <TableBodyCell>2</TableBodyCell>
                        </TableBodyRow>
                        <TableBodyRow>
                            <TableBodyCell>
                                <div class="flex items-center">
                                    <P size="sm" class="mr-3">Pedro</P>
                                    <img
                                        class="w-5 h-5 rounded-full"
                                        src="/images/placeholder.png"
                                        alt="Jese"
                                    />
                                </div>
                            </TableBodyCell>
                            <TableBodyCell>30</TableBodyCell>
                            <TableBodyCell>20</TableBodyCell>
                            <TableBodyCell>15</TableBodyCell>
                            <TableBodyCell>1.5</TableBodyCell>
                            <TableBodyCell>2</TableBodyCell>
                            <TableBodyCell>15</TableBodyCell>
                            <TableBodyCell>50%</TableBodyCell>
                            <TableBodyCell>5</TableBodyCell>
                            <TableBodyCell>3</TableBodyCell>
                            <TableBodyCell>5</TableBodyCell>
                            <TableBodyCell>2</TableBodyCell>
                        </TableBodyRow>
                        <TableBodyRow>
                            <TableBodyCell>
                                <div class="flex items-center">
                                    <P size="sm" class="mr-3">Pedro</P>
                                    <img
                                        class="w-5 h-5 rounded-full"
                                        src="/images/placeholder.png"
                                        alt="Jese"
                                    />
                                </div>
                            </TableBodyCell>
                            <TableBodyCell>30</TableBodyCell>
                            <TableBodyCell>20</TableBodyCell>
                            <TableBodyCell>15</TableBodyCell>
                            <TableBodyCell>1.5</TableBodyCell>
                            <TableBodyCell>2</TableBodyCell>
                            <TableBodyCell>15</TableBodyCell>
                            <TableBodyCell>50%</TableBodyCell>
                            <TableBodyCell>5</TableBodyCell>
                            <TableBodyCell>3</TableBodyCell>
                            <TableBodyCell>5</TableBodyCell>
                            <TableBodyCell>2</TableBodyCell>
                        </TableBodyRow>
                    </TableBody>
                </Table>
            </TabItem>
        </Tabs> 
    </div>
</div>